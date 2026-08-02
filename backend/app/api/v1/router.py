from fastapi import APIRouter

from app.api.v1.routers import (
    activities,
    assessment,
    auth,
    home,
    nutrition,
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
