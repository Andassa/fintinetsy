from fastapi import APIRouter, Query

from app.core.dependencies import DbSession
from app.schemas.search import SearchFilterOut, SearchPageOut, SearchSuggestionOut
from app.services.search_service import SearchService

router = APIRouter(prefix="/search", tags=["search"])
_service = SearchService()


@router.get("", response_model=SearchPageOut)
async def search(
    session: DbSession,
    q: str = "",
    filter: SearchFilterOut | None = None,
    cursor: str | None = None,
    limit: int = Query(default=20, ge=1, le=100),
) -> SearchPageOut:
    return await _service.search(session, q, filter, cursor, limit)


@router.get("/suggestions", response_model=list[SearchSuggestionOut])
async def suggestions(
    session: DbSession,
    q: str = "",
) -> list[SearchSuggestionOut]:
    return await _service.suggestions(session, q)
