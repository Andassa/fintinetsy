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
async def test_status_and_directions(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "status@uplift.ai")
    status = await client.get("/api/v1/activities/status", headers=headers)
    assert status.status_code == 200
    body = status.json()
    assert body["has_activities"] is False
    assert len(body["items"]) == 5

    directions = await client.get("/api/v1/activities/directions", headers=headers)
    assert directions.status_code == 200
    assert directions.json()["address"] == "3 Birrel Avenue"
    assert directions.json()["thumbnail_url"].startswith("https://")


@pytest.mark.asyncio
async def test_create_and_complete_activity(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "jog@uplift.ai")
    created = await client.post(
        "/api/v1/activities",
        headers=headers,
        json={"type": "jogging"},
    )
    assert created.status_code == 201
    activity = created.json()
    assert activity["type"] == "jogging"
    assert activity["ended_at"] is None

    status = await client.get("/api/v1/activities/status", headers=headers)
    assert status.json()["has_activities"] is True

    done = await client.post(
        f"/api/v1/activities/{activity['id']}/complete",
        headers=headers,
        json={"distance_m": 3200, "calories": 254, "avg_bpm": 140},
    )
    assert done.status_code == 200
    payload = done.json()
    assert "Completed" in payload["title"]
    assert payload["activity"]["avg_bpm"] == 140
    assert len(payload["segments"]) == 3

    again = await client.post(
        f"/api/v1/activities/{activity['id']}/complete",
        headers=headers,
        json={},
    )
    assert again.status_code == 422
