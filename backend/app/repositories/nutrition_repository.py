from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.nutrition import Meal
from app.repositories.base import GenericRepository


class MealRepository(GenericRepository[Meal]):
    def __init__(self) -> None:
        super().__init__(Meal)

    async def get_for_user(
        self,
        session: AsyncSession,
        meal_id: UUID,
        user_id: UUID,
    ) -> Meal | None:
        result = await session.execute(
            select(Meal).where(Meal.id == meal_id, Meal.user_id == user_id),
        )
        return result.scalar_one_or_none()
