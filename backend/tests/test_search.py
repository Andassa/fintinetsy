import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_search_suggestions(client: AsyncClient) -> None:
    all_sugs = await client.get("/api/v1/search/suggestions")
    assert all_sugs.status_code == 200
    assert len(all_sugs.json()) >= 6

    filtered = await client.get("/api/v1/search/suggestions", params={"q": "AI"})
    assert filtered.status_code == 200
    assert all("ai" in s["label"].lower() for s in filtered.json())


@pytest.mark.asyncio
async def test_search_results_and_not_found(client: AsyncClient) -> None:
    ok = await client.get("/api/v1/search", params={"q": "fitness", "limit": 10})
    assert ok.status_code == 200
    body = ok.json()
    assert len(body["items"]["items"]) >= 1
    assert "workout" in body["filters"]

    empty = await client.get("/api/v1/search", params={"q": "zzzz"})
    assert empty.status_code == 200
    assert empty.json()["items"]["items"] == []


@pytest.mark.asyncio
async def test_search_filter_workout(client: AsyncClient) -> None:
    response = await client.get(
        "/api/v1/search",
        params={"filter": "workout", "limit": 20},
    )
    assert response.status_code == 200
    for item in response.json()["items"]["items"]:
        assert item["filter"] == "workout"
