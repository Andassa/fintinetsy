from datetime import datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user import PasswordResetRequest, RefreshToken, User
from app.repositories.base import GenericRepository


class UserRepository(GenericRepository[User]):
    def __init__(self) -> None:
        super().__init__(User)

    async def get_by_email(self, session: AsyncSession, email: str) -> User | None:
        stmt = select(User).where(User.email == email.lower())
        result = await session.execute(stmt)
        return result.scalar_one_or_none()


class RefreshTokenRepository(GenericRepository[RefreshToken]):
    def __init__(self) -> None:
        super().__init__(RefreshToken)

    async def get_active_by_hash(
        self,
        session: AsyncSession,
        token_hash: str,
    ) -> RefreshToken | None:
        stmt = select(RefreshToken).where(
            RefreshToken.token_hash == token_hash,
            RefreshToken.revoked.is_(False),
        )
        result = await session.execute(stmt)
        return result.scalar_one_or_none()

    async def revoke(self, session: AsyncSession, token: RefreshToken) -> None:
        token.revoked = True
        await session.flush()

    async def revoke_all_for_user(self, session: AsyncSession, user_id: UUID) -> None:
        stmt = select(RefreshToken).where(
            RefreshToken.user_id == user_id,
            RefreshToken.revoked.is_(False),
        )
        result = await session.execute(stmt)
        for token in result.scalars().all():
            token.revoked = True
        await session.flush()


class PasswordResetRepository(GenericRepository[PasswordResetRequest]):
    def __init__(self) -> None:
        super().__init__(PasswordResetRequest)

    async def create_request(
        self,
        session: AsyncSession,
        user_id: UUID,
        method: str,
        sent_at: datetime,
    ) -> PasswordResetRequest:
        from app.models.user import ResetMethod

        entity = PasswordResetRequest(
            user_id=user_id,
            method=ResetMethod(method),
            sent_at=sent_at,
            consumed=False,
        )
        return await self.add(session, entity)
