import pytest
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import hash_password, verify_password
from app.models.user import Membership, User
from app.repositories.user_repository import UserRepository


@pytest.mark.asyncio
async def test_create_user_hashes_password(session: AsyncSession) -> None:
    repo = UserRepository()
    user = User(
        email="eren@uplift.ai",
        hashed_password=hash_password("secret123"),
        name="Eren",
        membership=Membership.basic,
    )
    saved = await repo.add(session, user)
    await session.commit()
    assert saved.hashed_password != "secret123"
    assert verify_password("secret123", saved.hashed_password)


@pytest.mark.asyncio
async def test_get_user_by_email_returns_none_when_absent(session: AsyncSession) -> None:
    repo = UserRepository()
    found = await repo.get_by_email(session, "missing@uplift.ai")
    assert found is None
