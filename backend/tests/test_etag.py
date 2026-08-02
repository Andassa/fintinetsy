import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_etag_browse_and_304(client: AsyncClient) -> None:
    first = await client.get("/api/v1/workouts/browse")
    assert first.status_code == 200
    etag = first.headers.get("etag")
    assert etag

    second = await client.get(
        "/api/v1/workouts/browse",
        headers={"If-None-Match": etag},
    )
    assert second.status_code == 304
