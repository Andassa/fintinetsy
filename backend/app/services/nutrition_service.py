from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException
from app.models.nutrition import Meal, MealEntryMethod, MealType
from app.repositories.nutrition_repository import MealRepository
from app.schemas.nutrition import (
    MealCreateRequest,
    MealDraftOut,
    MealEntryMethodOut,
    MealOut,
    MealScanOut,
    MealScanRequest,
    MealTypeOut,
)

CDN = "https://cdn.uplift.ai"


class NutritionService:
    def __init__(self) -> None:
        self.meals = MealRepository()

    def get_draft(self) -> MealDraftOut:
        return MealDraftOut(
            name="",
            type=MealTypeOut.dinner,
            protein_g=20,
            carbs_g=25,
            fat_g=15,
            entry_method=MealEntryMethodOut.manual,
            image_url=None,
        )

    async def create_meal(
        self,
        session: AsyncSession,
        user_id: UUID,
        body: MealCreateRequest,
    ) -> MealOut:
        logged_at = body.logged_at or datetime.now(UTC)
        meal = Meal(
            user_id=user_id,
            name=body.name.strip(),
            type=MealType(body.type.value),
            protein_g=body.protein_g,
            carbs_g=body.carbs_g,
            fat_g=body.fat_g,
            entry_method=MealEntryMethod(body.entry_method.value),
            image_url=body.image_url,
            logged_at=logged_at,
        )
        saved = await self.meals.add(session, meal)
        return self._to_out(saved)

    async def get_meal(
        self,
        session: AsyncSession,
        user_id: UUID,
        meal_id: UUID,
    ) -> MealOut:
        meal = await self.meals.get_for_user(session, meal_id, user_id)
        if meal is None:
            raise NotFoundException("Meal not found")
        return self._to_out(meal)

    def start_scan(self, body: MealScanRequest) -> MealScanOut:
        image = body.image_url or f"{CDN}/meals/power-bowl.jpg"
        return MealScanOut(
            image_url=image,
            status_label="Scanning...",
            progress=0.45,
        )

    def _to_out(self, meal: Meal) -> MealOut:
        return MealOut(
            id=meal.id,
            name=meal.name,
            type=MealTypeOut(meal.type.value),
            protein_g=meal.protein_g,
            carbs_g=meal.carbs_g,
            fat_g=meal.fat_g,
            entry_method=MealEntryMethodOut(meal.entry_method.value),
            image_url=meal.image_url,
            logged_at=meal.logged_at,
        )
