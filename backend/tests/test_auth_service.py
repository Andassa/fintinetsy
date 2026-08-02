import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import UnauthorizedException
from app.services.auth_service import AuthService


@pytest.mark.asyncio
async def test_login_with_wrong_password_raises_unauthorized(
    session: AsyncSession,
) -> None:
    auth = AuthService()
    await auth.register(session, "user@uplift.ai", "pass12345", "pass12345")
    await session.commit()
    with pytest.raises(UnauthorizedException):
        await auth.login(session, "user@uplift.ai", "wrongpass1")


@pytest.mark.asyncio
async def test_refresh_token_rotation_revokes_old_token(client: AsyncClient) -> None:
    register = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "rotate@uplift.ai",
            "password": "pass12345",
            "confirm_password": "pass12345",
        },
    )
    assert register.status_code == 201
    old_refresh = register.json()["refresh_token"]

    refreshed = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": old_refresh},
    )
    assert refreshed.status_code == 200
    new_refresh = refreshed.json()["refresh_token"]
    assert new_refresh != old_refresh

    reuse = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": old_refresh},
    )
    assert reuse.status_code == 401


@pytest.mark.asyncio
async def test_register_and_login_flow(client: AsyncClient) -> None:
    created = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "flow@uplift.ai",
            "password": "pass12345",
            "confirm_password": "pass12345",
        },
    )
    assert created.status_code == 201
    body = created.json()
    assert "access_token" in body
    assert body["user"]["email"] == "flow@uplift.ai"

    login = await client.post(
        "/api/v1/auth/login",
        json={"email": "flow@uplift.ai", "password": "pass12345"},
    )
    assert login.status_code == 200
    token = login.json()["access_token"]
    me = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert me.status_code == 200
