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
async def test_meal_draft_defaults(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "draft@uplift.ai")
    response = await client.get("/api/v1/meals/draft", headers=headers)
    assert response.status_code == 200
    body = response.json()
    assert body["type"] == "dinner"
    assert body["protein_g"] == 20
    assert body["carbs_g"] == 25
    assert body["fat_g"] == 15
    assert body["entry_method"] == "manual"


@pytest.mark.asyncio
async def test_create_and_get_meal(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "meal@uplift.ai")
    created = await client.post(
        "/api/v1/meals",
        headers=headers,
        json={
            "name": "Grilled chicken",
            "type": "dinner",
            "protein_g": 40,
            "carbs_g": 12,
            "fat_g": 8,
            "entry_method": "manual",
        },
    )
    assert created.status_code == 201
    meal = created.json()
    assert meal["name"] == "Grilled chicken"
    assert meal["protein_g"] == 40
    assert meal["id"]

    fetched = await client.get(f"/api/v1/meals/{meal['id']}", headers=headers)
    assert fetched.status_code == 200
    assert fetched.json()["name"] == "Grilled chicken"


@pytest.mark.asyncio
async def test_meal_not_found_for_other_user(client: AsyncClient) -> None:
    owner = await _auth_headers(client, "owner@uplift.ai")
    other = await _auth_headers(client, "other@uplift.ai")
    created = await client.post(
        "/api/v1/meals",
        headers=owner,
        json={
            "name": "Secret salad",
            "type": "lunch",
            "protein_g": 10,
            "carbs_g": 20,
            "fat_g": 5,
        },
    )
    meal_id = created.json()["id"]
    response = await client.get(f"/api/v1/meals/{meal_id}", headers=other)
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_start_scan(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "scan@uplift.ai")
    response = await client.post("/api/v1/meals/scan", headers=headers, json={})
    assert response.status_code == 200
    body = response.json()
    assert "Scanning" in body["status_label"]
    assert 0 < body["progress"] < 1
    assert body["image_url"].startswith("https://")
