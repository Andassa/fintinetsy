import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_assessment_config_returns_goals_and_ranges(client: AsyncClient) -> None:
    response = await client.get("/api/v1/assessment/config")
    assert response.status_code == 200
    body = response.json()
    assert body["min_age"] == 12
    assert body["max_age"] == 80
    assert len(body["fitness_labels"]) == 6
    assert len(body["goals"]) == 5
    codes = {g["id"] for g in body["goals"]}
    assert "lose_weight" in codes
    assert "bulk" in codes
    assert "prompt" in body["vocal"]


@pytest.mark.asyncio
async def test_put_assessment_persists_avatar_and_goal(client: AsyncClient) -> None:
    register = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "assess@uplift.ai",
            "password": "pass12345",
            "confirm_password": "pass12345",
        },
    )
    assert register.status_code == 201
    token = register.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    updated = await client.put(
        "/api/v1/users/me/assessment",
        headers=headers,
        json={
            "age": 25,
            "weight_kg": 70.5,
            "weight_unit": "kg",
            "fitness_level": 4,
            "gender": "male",
            "goal_id": "bulk",
            "avatar_id": "avatar_center",
            "vocal_completed": True,
        },
    )
    assert updated.status_code == 200
    body = updated.json()
    assert body["age"] == 25
    assert body["goal_id"] == "bulk"
    assert body["avatar_id"] == "avatar_center"
    assert body["vocal_completed"] is True

    fetched = await client.get("/api/v1/users/me/assessment", headers=headers)
    assert fetched.status_code == 200
    assert fetched.json()["goal_id"] == "bulk"


@pytest.mark.asyncio
async def test_age_out_of_range_rejected(client: AsyncClient) -> None:
    register = await client.post(
        "/api/v1/auth/register",
        json={
            "email": "agebad@uplift.ai",
            "password": "pass12345",
            "confirm_password": "pass12345",
        },
    )
    token = register.json()["access_token"]
    response = await client.put(
        "/api/v1/users/me/assessment",
        headers={"Authorization": f"Bearer {token}"},
        json={"age": 5},
    )
    assert response.status_code == 422
    assert response.json()["code"] == "validation_error"
