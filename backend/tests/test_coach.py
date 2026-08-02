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
async def test_coach_hub_and_chats(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "coach@uplift.ai")
    hub = await client.get("/api/v1/coach/hub", headers=headers)
    assert hub.status_code == 200
    body = hub.json()
    assert body["model_label"] == "Gpt4.0"
    assert len(body["conversations"]) >= 1
    assert "Pro" in body["pro_title"]

    chats = await client.get(
        "/api/v1/coach/chats",
        headers=headers,
        params={"tab": "ai", "limit": 3},
    )
    assert chats.status_code == 200
    page = chats.json()
    assert len(page["items"]) == 3
    assert page["has_more"] is True


@pytest.mark.asyncio
async def test_messages_and_send(client: AsyncClient) -> None:
    headers = await _auth_headers(client, "thread@uplift.ai")
    chats = await client.get("/api/v1/coach/chats", headers=headers)
    chat_id = chats.json()["items"][0]["id"]

    thread = await client.get(
        f"/api/v1/coach/chats/{chat_id}/messages",
        headers=headers,
    )
    assert thread.status_code == 200
    body = thread.json()
    assert body["bot_name"] == "Uplift"
    assert len(body["messages"]["items"]) >= 5
    kinds = {m["kind"] for m in body["messages"]["items"]}
    assert "bot" in kinds
    assert "bot_card" in kinds

    sent = await client.post(
        f"/api/v1/coach/chats/{chat_id}/messages",
        headers=headers,
        json={"text": "Plan my week"},
    )
    assert sent.status_code == 201
    assert sent.json()["kind"] == "user"
    assert sent.json()["text"] == "Plan my week"
