from datetime import datetime
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.stats import CalorieLog, HeartRateLog, HydrationLog, UserStatsGoals
from app.repositories.base import GenericRepository


class UserStatsGoalsRepository(GenericRepository[UserStatsGoals]):
    def __init__(self) -> None:
        super().__init__(UserStatsGoals)

    async def get_or_none(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> UserStatsGoals | None:
        return await session.get(UserStatsGoals, user_id)


class HydrationLogRepository(GenericRepository[HydrationLog]):
    def __init__(self) -> None:
        super().__init__(HydrationLog)

    async def sum_between(
        self,
        session: AsyncSession,
        user_id: UUID,
        start: datetime,
        end: datetime,
    ) -> float:
        result = await session.execute(
            select(func.coalesce(func.sum(HydrationLog.value), 0.0)).where(
                HydrationLog.user_id == user_id,
                HydrationLog.recorded_at >= start,
                HydrationLog.recorded_at < end,
            ),
        )
        return float(result.scalar_one())


class HeartRateLogRepository(GenericRepository[HeartRateLog]):
    def __init__(self) -> None:
        super().__init__(HeartRateLog)

    async def latest(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> HeartRateLog | None:
        result = await session.execute(
            select(HeartRateLog)
            .where(HeartRateLog.user_id == user_id)
            .order_by(HeartRateLog.recorded_at.desc())
            .limit(1),
        )
        return result.scalar_one_or_none()


class CalorieLogRepository(GenericRepository[CalorieLog]):
    def __init__(self) -> None:
        super().__init__(CalorieLog)

    async def sum_between(
        self,
        session: AsyncSession,
        user_id: UUID,
        start: datetime,
        end: datetime,
    ) -> float:
        result = await session.execute(
            select(func.coalesce(func.sum(CalorieLog.value), 0.0)).where(
                CalorieLog.user_id == user_id,
                CalorieLog.recorded_at >= start,
                CalorieLog.recorded_at < end,
            ),
        )
        return float(result.scalar_one())

    async def list_recent(
        self,
        session: AsyncSession,
        user_id: UUID,
        limit: int = 6,
    ) -> list[CalorieLog]:
        result = await session.execute(
            select(CalorieLog)
            .where(CalorieLog.user_id == user_id)
            .order_by(CalorieLog.recorded_at.desc())
            .limit(limit),
        )
        return list(result.scalars().all())
