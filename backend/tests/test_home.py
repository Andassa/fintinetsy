import pytest
from httpx import AsyncClient


async def _auth_headers(client: AsyncClient, email: str) -> dict[str, str]:
    response = await client.post(
        "/api/v1/auth/register",
        json={
            "email": email,
            "password": "pass12345",
            "confirm_password": "pass12345",
        },
    )
    assert response.status_code == 201
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


@pytest.mark.asyncio
async def test_dashboard_requires_auth(client: AsyncClient) -> None:
    response = await client.get("/api/v1/home/dashboard")
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_dashboard_returns_typed_payload(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "home@uplift.ai")
    response = await client.get("/api/v1/home/dashboard", headers=headers)
    assert response.status_code == 200
    body = response.json()
    assert body["user"]["name"] == "home"
    assert "date" in body["user"]
    assert isinstance(body["workout"]["duration_minutes"], int)
    assert isinstance(body["workout"]["calories"], int)
    assert body["workout"]["image_url"].startswith("https://")
    assert len(body["categories"]) == 3
    assert len(body["activities"]) == 5
    assert isinstance(body["ai_coach"]["conversations_count"], int)
    assert body["diet"]["protein_g"] == 25
