from uuid import UUID

from fastapi import APIRouter, Query

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.settings import (
    NotificationOut,
    NotificationPageOut,
    NotificationScopeOut,
)
from app.services.settings_service import SettingsService

router = APIRouter(prefix="/notifications", tags=["notifications"])
_service = SettingsService()


@router.get("", response_model=NotificationPageOut)
async def list_notifications(
    session: DbSession,
    user: CurrentUser,
    scope: NotificationScopeOut = NotificationScopeOut.today,
    cursor: str | None = None,
    limit: int = Query(default=20, ge=1, le=100),
) -> NotificationPageOut:
    return await _service.list_notifications(session, user.id, scope, cursor, limit)


@router.patch("/{notification_id}/read", response_model=NotificationOut)
async def mark_notification_read(
    notification_id: UUID,
    session: DbSession,
    user: CurrentUser,
) -> NotificationOut:
    return await _service.mark_read(session, user.id, notification_id)
