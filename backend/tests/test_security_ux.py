import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_login_failure_is_generic(client: AsyncClient) -> None:
    response = await client.post(
        "/api/v1/auth/login",
        json={"email": "nobody@uplift.ai", "password": "wrongpass1"},
    )
    assert response.status_code == 401
    body = response.json()
    assert body["code"] == "unauthorized"
    assert body["message"] == "identifiants invalides"
    assert "details" in body
    assert "email" not in body["message"].lower() or "password" not in body["message"]


@pytest.mark.asyncio
async def test_validation_error_envelope(client: AsyncClient) -> None:
    response = await client.post(
        "/api/v1/auth/register",
        json={"email": "not-an-email", "password": "x", "confirm_password": "y"},
    )
    assert response.status_code == 422
    body = response.json()
    assert body["code"] == "validation_error"
    assert "message" in body
    assert "details" in body
