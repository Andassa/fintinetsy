from uuid import UUID

from fastapi import APIRouter

from app.core.dependencies import CurrentUser, DbSession
from app.core.pagination import CursorQuery, LimitQuery
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
    cursor: CursorQuery = None,
    limit: LimitQuery = 20,
) -> NotificationPageOut:
    return await _service.list_notifications(session, user.id, scope, cursor, limit)


@router.patch("/{notification_id}/read", response_model=NotificationOut)
async def mark_notification_read(
    notification_id: UUID,
    session: DbSession,
    user: CurrentUser,
) -> NotificationOut:
    return await _service.mark_read(session, user.id, notification_id)
