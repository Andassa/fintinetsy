from fastapi import APIRouter

from app.api.v1.routers import assessment, auth, home, workouts

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(assessment.router)
api_router.include_router(home.router)
api_router.include_router(workouts.router)
