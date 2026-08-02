from uuid import UUID

from fastapi import APIRouter, status

from app.core.dependencies import CurrentUser, DbSession
from app.core.pagination import CursorQuery, LimitQuery
from app.schemas.workout import (
    WorkoutBrowseOut,
    WorkoutCategoryOut,
    WorkoutCompleteOut,
    WorkoutCompleteRequest,
    WorkoutDetailOut,
)
from app.services.workout_service import WorkoutService

router = APIRouter(prefix="/workouts", tags=["workouts"])
_service = WorkoutService()


@router.get("/browse", response_model=WorkoutBrowseOut)
async def get_browse(session: DbSession) -> WorkoutBrowseOut:
    return await _service.get_browse(session)


@router.get("/categories/{category_id}", response_model=WorkoutCategoryOut)
async def get_category(
    category_id: str,
    session: DbSession,
    cursor: CursorQuery = None,
    limit: LimitQuery = 20,
) -> WorkoutCategoryOut:
    return await _service.get_category(session, category_id, cursor, limit)


@router.get("/{workout_id}", response_model=WorkoutDetailOut)
async def get_workout(
    workout_id: UUID,
    session: DbSession,
) -> WorkoutDetailOut:
    return await _service.get_workout(session, workout_id)


@router.post(
    "/{workout_id}/complete",
    response_model=WorkoutCompleteOut,
    status_code=status.HTTP_201_CREATED,
)
async def complete_workout(
    workout_id: UUID,
    body: WorkoutCompleteRequest,
    session: DbSession,
    user: CurrentUser,
) -> WorkoutCompleteOut:
    return await _service.complete_workout(session, user.id, workout_id, body)
