from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.home import (
    HomeActivityBlobLayout,
    HomeAiCoachCardSeed,
    HomeCategory,
    HomeFeaturedMeal,
    HomeFeaturedWorkout,
)
from app.repositories.base import GenericRepository


class HomeCategoryRepository(GenericRepository[HomeCategory]):
    def __init__(self) -> None:
        super().__init__(HomeCategory)

    async def list_ordered(self, session: AsyncSession) -> list[HomeCategory]:
        result = await session.execute(
            select(HomeCategory).order_by(HomeCategory.sort_order),
        )
        return list(result.scalars().all())


class HomeFeaturedWorkoutRepository(GenericRepository[HomeFeaturedWorkout]):
    def __init__(self) -> None:
        super().__init__(HomeFeaturedWorkout)

    async def get_active(self, session: AsyncSession) -> HomeFeaturedWorkout | None:
        result = await session.execute(
            select(HomeFeaturedWorkout)
            .where(HomeFeaturedWorkout.is_active.is_(True))
            .limit(1),
        )
        return result.scalar_one_or_none()


class HomeFeaturedMealRepository(GenericRepository[HomeFeaturedMeal]):
    def __init__(self) -> None:
        super().__init__(HomeFeaturedMeal)

    async def get_active(self, session: AsyncSession) -> HomeFeaturedMeal | None:
        result = await session.execute(
            select(HomeFeaturedMeal)
            .where(HomeFeaturedMeal.is_active.is_(True))
            .limit(1),
        )
        return result.scalar_one_or_none()


class HomeActivityBlobRepository(GenericRepository[HomeActivityBlobLayout]):
    def __init__(self) -> None:
        super().__init__(HomeActivityBlobLayout)

    async def list_ordered(self, session: AsyncSession) -> list[HomeActivityBlobLayout]:
        result = await session.execute(
            select(HomeActivityBlobLayout).order_by(HomeActivityBlobLayout.sort_order),
        )
        return list(result.scalars().all())


class HomeAiCoachSeedRepository(GenericRepository[HomeAiCoachCardSeed]):
    def __init__(self) -> None:
        super().__init__(HomeAiCoachCardSeed)

    async def get_active(self, session: AsyncSession) -> HomeAiCoachCardSeed | None:
        result = await session.execute(
            select(HomeAiCoachCardSeed)
            .where(HomeAiCoachCardSeed.is_active.is_(True))
            .limit(1),
        )
        return result.scalar_one_or_none()
