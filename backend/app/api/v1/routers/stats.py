from fastapi import APIRouter, status

from app.core.dependencies import CurrentUser, DbSession
from app.schemas.stats import (
    CalorieIntakeOut,
    CalorieStatsOut,
    HeartRateOut,
    HydrationLogOut,
    HydrationLogRequest,
    HydrationOut,
    UpliftScoreOut,
)
from app.services.stats_service import StatsService

router = APIRouter(prefix="/stats", tags=["stats"])
_service = StatsService()


@router.get("/hydration", response_model=HydrationOut)
async def get_hydration(session: DbSession, user: CurrentUser) -> HydrationOut:
    return await _service.get_hydration(session, user.id)


@router.post(
    "/hydration",
    response_model=HydrationLogOut,
    status_code=status.HTTP_201_CREATED,
)
async def log_hydration(
    body: HydrationLogRequest,
    session: DbSession,
    user: CurrentUser,
) -> HydrationLogOut:
    return await _service.log_hydration(session, user.id, body)


@router.get("/heart-rate", response_model=HeartRateOut)
async def get_heart_rate(session: DbSession, user: CurrentUser) -> HeartRateOut:
    return await _service.get_heart_rate(session, user.id)


@router.get("/calories", response_model=CalorieStatsOut)
async def get_calorie_stats(
    session: DbSession,
    user: CurrentUser,
) -> CalorieStatsOut:
    return await _service.get_calorie_stats(session, user.id)


@router.get("/calories/intake", response_model=CalorieIntakeOut)
async def get_calorie_intake(
    session: DbSession,
    user: CurrentUser,
) -> CalorieIntakeOut:
    return await _service.get_calorie_intake(session, user.id)


@router.get("/uplift-score", response_model=UpliftScoreOut)
async def get_uplift_score(user: CurrentUser) -> UpliftScoreOut:
    _ = user
    return _service.get_uplift_score()
