from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.assessment import AssessmentConfigRow, AssessmentProfile, FitnessGoal
from app.repositories.base import GenericRepository


class FitnessGoalRepository(GenericRepository[FitnessGoal]):
    def __init__(self) -> None:
        super().__init__(FitnessGoal)

    async def list_all_ordered(self, session: AsyncSession) -> list[FitnessGoal]:
        result = await session.execute(select(FitnessGoal).order_by(FitnessGoal.code))
        return list(result.scalars().all())

    async def get_by_code(self, session: AsyncSession, code: str) -> FitnessGoal | None:
        result = await session.execute(
            select(FitnessGoal).where(FitnessGoal.code == code),
        )
        return result.scalar_one_or_none()


class AssessmentConfigRepository(GenericRepository[AssessmentConfigRow]):
    def __init__(self) -> None:
        super().__init__(AssessmentConfigRow)

    async def get_singleton(self, session: AsyncSession) -> AssessmentConfigRow | None:
        result = await session.execute(select(AssessmentConfigRow).limit(1))
        return result.scalar_one_or_none()


class AssessmentProfileRepository(GenericRepository[AssessmentProfile]):
    def __init__(self) -> None:
        super().__init__(AssessmentProfile)

    async def get_for_user(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> AssessmentProfile | None:
        result = await session.execute(
            select(AssessmentProfile)
            .where(AssessmentProfile.user_id == user_id)
            .options(selectinload(AssessmentProfile.goal)),
        )
        return result.scalar_one_or_none()

    async def upsert_for_user(
        self,
        session: AsyncSession,
        profile: AssessmentProfile,
    ) -> AssessmentProfile:
        merged = await session.merge(profile)
        await session.flush()
        await session.refresh(merged)
        return merged
