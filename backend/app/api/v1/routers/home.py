from fastapi import APIRouter

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.home import HomeDashboardOut
from app.services.home_service import HomeService

router = APIRouter(prefix="/home", tags=["home"])
_service = HomeService()


@router.get("/dashboard", response_model=HomeDashboardOut)
async def get_dashboard(
    session: DbSession,
    user: CurrentUser,
) -> HomeDashboardOut:
    return await _service.get_dashboard(session, user)
