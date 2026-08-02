from uuid import UUID

from fastapi import APIRouter, status

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.nutrition import (
    MealCreateRequest,
    MealDraftOut,
    MealOut,
    MealScanOut,
    MealScanRequest,
)
from app.services.nutrition_service import NutritionService

router = APIRouter(prefix="/meals", tags=["nutrition"])
_service = NutritionService()


@router.get("/draft", response_model=MealDraftOut)
async def get_meal_draft(user: CurrentUser) -> MealDraftOut:
    _ = user
    return _service.get_draft()


@router.post(
    "/scan",
    response_model=MealScanOut,
    status_code=status.HTTP_200_OK,
)
async def start_meal_scan(
    body: MealScanRequest,
    user: CurrentUser,
) -> MealScanOut:
    _ = user
    return _service.start_scan(body)


@router.post(
    "",
    response_model=MealOut,
    status_code=status.HTTP_201_CREATED,
)
async def create_meal(
    body: MealCreateRequest,
    session: DbSession,
    user: CurrentUser,
) -> MealOut:
    return await _service.create_meal(session, user.id, body)


@router.get("/{meal_id}", response_model=MealOut)
async def get_meal(
    meal_id: UUID,
    session: DbSession,
    user: CurrentUser,
) -> MealOut:
    return await _service.get_meal(session, user.id, meal_id)
