from uuid import UUID

from fastapi import APIRouter, status

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.activity import (
    ActivityCompleteOut,
    ActivityCompleteRequest,
    ActivityCreateRequest,
    ActivityOut,
    ActivityStatusOut,
    DirectionsOut,
)
from app.services.activity_service import ActivityService

router = APIRouter(prefix="/activities", tags=["activities"])
_service = ActivityService()


@router.get("/status", response_model=ActivityStatusOut)
async def get_activity_status(
    session: DbSession,
    user: CurrentUser,
) -> ActivityStatusOut:
    return await _service.get_status(session, user.id)


@router.get("/directions", response_model=DirectionsOut)
async def get_directions(user: CurrentUser) -> DirectionsOut:
    _ = user
    return _service.get_directions()


@router.post(
    "",
    response_model=ActivityOut,
    status_code=status.HTTP_201_CREATED,
)
async def create_activity(
    body: ActivityCreateRequest,
    session: DbSession,
    user: CurrentUser,
) -> ActivityOut:
    return await _service.create_activity(session, user.id, body)


@router.post(
    "/{activity_id}/complete",
    response_model=ActivityCompleteOut,
    status_code=status.HTTP_200_OK,
)
async def complete_activity(
    activity_id: UUID,
    body: ActivityCompleteRequest,
    session: DbSession,
    user: CurrentUser,
) -> ActivityCompleteOut:
    return await _service.complete_activity(session, user.id, activity_id, body)
