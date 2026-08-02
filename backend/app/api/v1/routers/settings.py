from fastapi import APIRouter

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.settings import SettingsOut, SettingsPatchRequest
from app.services.settings_service import SettingsService

router = APIRouter(prefix="/settings", tags=["settings"])
_service = SettingsService()


@router.get("", response_model=SettingsOut)
async def get_settings(session: DbSession, user: CurrentUser) -> SettingsOut:
    return await _service.get_settings(session, user.id)


@router.patch("", response_model=SettingsOut)
async def patch_settings(
    body: SettingsPatchRequest,
    session: DbSession,
    user: CurrentUser,
) -> SettingsOut:
    return await _service.patch_settings(session, user.id, body)
