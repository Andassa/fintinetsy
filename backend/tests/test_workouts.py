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
async def test_browse_page(client: AsyncClient) -> None:
    response = await client.get("/api/v1/workouts/browse")
    assert response.status_code == 200
    body = response.json()
    assert "Personalized" in body["title"]
    assert body["dot_count"] == 3


@pytest.mark.asyncio
async def test_category_cursor_pagination(client: AsyncClient) -> None:
    first = await client.get(
        "/api/v1/workouts/categories/strength",
        params={"limit": 2},
    )
    assert first.status_code == 200
    body = first.json()
    assert body["code"] == "strength"
    assert body["total_workouts"] == 4
    assert len(body["items"]["items"]) == 2
    assert body["items"]["has_more"] is True
    cursor = body["items"]["next_cursor"]
    assert cursor

    second = await client.get(
        "/api/v1/workouts/categories/strength",
        params={"limit": 2, "cursor": cursor},
    )
    assert second.status_code == 200
    page2 = second.json()["items"]
    assert len(page2["items"]) == 2
    ids1 = {i["id"] for i in body["items"]["items"]}
    ids2 = {i["id"] for i in page2["items"]}
    assert ids1.isdisjoint(ids2)


@pytest.mark.asyncio
async def test_complete_workout_creates_session(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "workout@uplift.ai")
    category = await client.get("/api/v1/workouts/categories/strength")
    workout_id = category.json()["items"]["items"][0]["id"]

    detail = await client.get(f"/api/v1/workouts/{workout_id}")
    assert detail.status_code == 200
    assert detail.json()["duration_minutes"] == 58
    assert detail.json()["sets"] == 3

    done = await client.post(
        f"/api/v1/workouts/{workout_id}/complete",
        headers=headers,
        json={"duration_minutes": 60, "calories_burned": 300, "avg_bpm": 140},
    )
    assert done.status_code == 201
    payload = done.json()
    assert payload["calories_burned"] == 300
    assert payload["avg_bpm"] == 140
    assert "Complete" in payload["title"]
