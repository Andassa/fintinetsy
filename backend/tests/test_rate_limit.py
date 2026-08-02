import os

import pytest
from httpx import ASGITransport, AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine

from app.core.config import get_settings
from app.core.rate_limit import _limiter
from app.db.base import Base
from app.db.session import get_db
from app.main import app


@pytest.mark.asyncio
async def test_login_rate_limit_returns_429() -> None:
    os.environ["RATE_LIMIT_ENABLED"] = "true"
    os.environ["RATE_LIMIT_AUTH_LIMIT"] = "3"
    os.environ["RATE_LIMIT_AUTH_WINDOW_SECONDS"] = "900"
    get_settings.cache_clear()
    _limiter._hits.clear()

    engine = create_async_engine(
        "sqlite+aiosqlite:///:memory:",
        connect_args={"check_same_thread": False},
    )
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    factory = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with factory() as session:

        async def _override_db():
            try:
                yield session
                await session.commit()
            except Exception:
                await session.rollback()
                raise

        app.dependency_overrides[get_db] = _override_db
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            payload = {"email": "rate@uplift.ai", "password": "wrongpass1"}
            codes = []
            for _ in range(4):
                response = await client.post("/api/v1/auth/login", json=payload)
                codes.append(response.status_code)
            assert codes[:3] != [429, 429, 429]
            assert codes[-1] == 429
            assert response.json()["code"] == "rate_limited"

        app.dependency_overrides.clear()
    await engine.dispose()

    os.environ["RATE_LIMIT_ENABLED"] = "false"
    get_settings.cache_clear()
    _limiter._hits.clear()
