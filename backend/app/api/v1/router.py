from fastapi import APIRouter

from app.api.v1.routers import (
    activities,
    assessment,
    auth,
    coach,
    home,
    notifications,
    nutrition,
    search,
    settings,
    stats,
    workouts,
)

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(assessment.router)
api_router.include_router(home.router)
api_router.include_router(workouts.router)
api_router.include_router(nutrition.router)
api_router.include_router(stats.router)
api_router.include_router(activities.router)
api_router.include_router(coach.router)
api_router.include_router(settings.router)
api_router.include_router(notifications.router)
api_router.include_router(search.router)
