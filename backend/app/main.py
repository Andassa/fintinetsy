from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1.router import api_router
from app.core.config import get_settings
from app.core.etag import ETagMiddleware
from app.core.exceptions import AppException, app_exception_handler
from app.db.base import Base
from app.db.session import AsyncSessionLocal, engine
from app import models  # noqa: F401 — register models
from app.services.assessment_service import AssessmentService
from app.services.home_service import HomeService
from app.services.search_service import SearchService
from app.services.workout_service import WorkoutService


@asynccontextmanager
async def lifespan(_: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with AsyncSessionLocal() as session:
        await AssessmentService().ensure_seed_data(session)
        await HomeService().ensure_seed_data(session)
        await WorkoutService().ensure_seed_data(session)
        await SearchService().ensure_seed_data(session)
        await session.commit()
    yield
    await engine.dispose()


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(
        title=settings.app_name,
        debug=settings.debug,
        lifespan=lifespan,
    )
    app.add_exception_handler(AppException, app_exception_handler)
    if settings.etag_enabled:
        app.add_middleware(ETagMiddleware)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.include_router(api_router, prefix=settings.api_v1_prefix)

    @app.get("/health")
    async def health() -> dict[str, str]:
        return {"status": "ok"}

    return app


app = create_app()
