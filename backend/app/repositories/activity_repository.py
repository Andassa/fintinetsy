from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.activity import Activity
from app.repositories.base import GenericRepository


class ActivityRepository(GenericRepository[Activity]):
    def __init__(self) -> None:
        super().__init__(Activity)

    async def get_for_user(
        self,
        session: AsyncSession,
        activity_id: UUID,
        user_id: UUID,
    ) -> Activity | None:
        result = await session.execute(
            select(Activity).where(
                Activity.id == activity_id,
                Activity.user_id == user_id,
            ),
        )
        return result.scalar_one_or_none()

    async def list_for_user(
        self,
        session: AsyncSession,
        user_id: UUID,
        limit: int = 100,
    ) -> list[Activity]:
        result = await session.execute(
            select(Activity)
            .where(Activity.user_id == user_id)
            .order_by(Activity.started_at.desc())
            .limit(limit),
        )
        return list(result.scalars().all())
