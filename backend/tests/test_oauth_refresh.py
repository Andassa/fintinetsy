import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_oauth_google_mock_issues_jwt(client: AsyncClient) -> None:
    response = await client.post(
        "/api/v1/auth/oauth/google",
        json={
            "id_token": "mock.oauth.demo@uplift.ai",
            "email": "oauth.demo@uplift.ai",
            "name": "OAuth Demo",
        },
    )
    assert response.status_code == 200
    body = response.json()
    assert body["access_token"]
    assert body["refresh_token"]
    assert body["user"]["email"] == "oauth.demo@uplift.ai"

    me = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {body['access_token']}"},
    )
    assert me.status_code == 200


@pytest.mark.asyncio
async def test_refresh_rotates_tokens(client: AsyncClient) -> None:
    registered = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "refresh.user@uplift.ai",
            "password": "pass12345",
            "confirm_password": "pass12345",
        },
    )
    assert registered.status_code == 201
    refresh = registered.json()["refresh_token"]

    rotated = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": refresh},
    )
    assert rotated.status_code == 200
    assert rotated.json()["access_token"]
    assert rotated.json()["refresh_token"] != refresh
