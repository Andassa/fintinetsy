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
async def test_settings_get_and_patch(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "settings@uplift.ai")
    response = await client.get("/api/v1/settings", headers=headers)
    assert response.status_code == 200
    body = response.json()
    assert body["dark_mode"] is False
    assert len(body["sections"]) == 2

    patched = await client.patch(
        "/api/v1/settings",
        headers=headers,
        json={"dark_mode": True},
    )
    assert patched.status_code == 200
    assert patched.json()["dark_mode"] is True


@pytest.mark.asyncio
async def test_notifications_scope_and_mark_read(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "notif@uplift.ai")
    today = await client.get(
        "/api/v1/notifications",
        headers=headers,
        params={"scope": "today"},
    )
    assert today.status_code == 200
    today_body = today.json()
    assert today_body["scope"] == "today"
    assert len(today_body["items"]["items"]) == 3

    past = await client.get(
        "/api/v1/notifications",
        headers=headers,
        params={"scope": "past"},
    )
    assert past.status_code == 200
    assert len(past.json()["items"]["items"]) == 3

    notif_id = today_body["items"]["items"][0]["id"]
    assert today_body["items"]["items"][0]["is_read"] is False

    read = await client.patch(
        f"/api/v1/notifications/{notif_id}/read",
        headers=headers,
    )
    assert read.status_code == 200
    assert read.json()["is_read"] is True
