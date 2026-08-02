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
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


@pytest.mark.asyncio
async def test_hydration_log_updates_totals(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "hydrate@uplift.ai")
    empty = await client.get("/api/v1/stats/hydration", headers=headers)
    assert empty.status_code == 200
    assert empty.json()["current_ml"] == 0
    assert empty.json()["goal_ml"] == 2000
    assert empty.json()["needed_ml"] == 2000

    logged = await client.post(
        "/api/v1/stats/hydration",
        headers=headers,
        json={"amount_ml": 500},
    )
    assert logged.status_code == 201
    stats = logged.json()["stats"]
    assert stats["current_ml"] == 500
    assert stats["needed_ml"] == 1500


@pytest.mark.asyncio
async def test_heart_rate_defaults(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "hr@uplift.ai")
    response = await client.get("/api/v1/stats/heart-rate", headers=headers)
    assert response.status_code == 200
    body = response.json()
    assert body["bpm"] == 112
    assert "Basketball" in body["activity_label"]
    assert body["hero_image_url"].startswith("https://")


@pytest.mark.asyncio
async def test_calorie_endpoints(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "cal@uplift.ai")
    stats = await client.get("/api/v1/stats/calories", headers=headers)
    assert stats.status_code == 200
    assert stats.json()["total_kcal"] == 318
    assert len(stats.json()["macros"]) == 4

    intake = await client.get("/api/v1/stats/calories/intake", headers=headers)
    assert intake.status_code == 200
    body = intake.json()
    assert body["total_kcal"] == 1745
    assert body["remaining_kcal"] == 158
    assert len(body["points"]) == 6


@pytest.mark.asyncio
async def test_uplift_score(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "score@uplift.ai")
    response = await client.get("/api/v1/stats/uplift-score", headers=headers)
    assert response.status_code == 200
    body = response.json()
    assert body["score"] == 88
    assert len(body["segments"]) == 3
