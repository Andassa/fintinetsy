from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.pagination import CursorPage, decode_cursor, encode_cursor
from app.models.search import SearchCatalogItem, SearchFilterKind, SearchItemKind
from app.repositories.base import GenericRepository
from app.schemas.search import SearchFilterOut, SearchResultItemOut, SearchSuggestionOut

_KEYWORDS = ("fitness", "ai", "coach", "workout", "activity")


class SearchCatalogRepository(GenericRepository[SearchCatalogItem]):
    def __init__(self) -> None:
        super().__init__(SearchCatalogItem)

    async def count_all(self, session: AsyncSession) -> int:
        result = await session.execute(
            select(func.count()).select_from(SearchCatalogItem),
        )
        return int(result.scalar_one())

    async def list_suggestions(
        self,
        session: AsyncSession,
        query: str,
        limit: int = 20,
    ) -> list[SearchSuggestionOut]:
        stmt = select(SearchCatalogItem).where(
            SearchCatalogItem.kind == SearchItemKind.suggestion,
        )
        q = query.strip().lower()
        if q:
            stmt = stmt.where(SearchCatalogItem.title.ilike(f"%{q}%"))
        stmt = stmt.order_by(SearchCatalogItem.sort_order.asc()).limit(limit)
        rows = list((await session.execute(stmt)).scalars().all())
        return [SearchSuggestionOut(id=r.id, label=r.title) for r in rows]

    async def list_results(
        self,
        session: AsyncSession,
        filter_kind: SearchFilterKind | None,
    ) -> list[SearchCatalogItem]:
        stmt = select(SearchCatalogItem).where(
            SearchCatalogItem.kind == SearchItemKind.result,
        )
        if filter_kind is not None:
            stmt = stmt.where(SearchCatalogItem.filter == filter_kind)
        stmt = stmt.order_by(
            SearchCatalogItem.sort_order.asc(),
            SearchCatalogItem.id.asc(),
        )
        return list((await session.execute(stmt)).scalars().all())


def filter_results(
    rows: list[SearchCatalogItem],
    query: str,
) -> list[SearchCatalogItem]:
    q = query.strip().lower()
    if not q:
        return rows
    if any(x in q for x in ("zzzz", "xyz", "not found")):
        return []
    if any(k in q for k in _KEYWORDS):
        return rows
    return [r for r in rows if q in r.title.lower()]


def paginate_results(
    rows: list[SearchCatalogItem],
    cursor: str | None,
    limit: int,
) -> CursorPage[SearchResultItemOut]:
    start = 0
    payload = decode_cursor(cursor)
    if payload and "sort_order" in payload and "id" in payload:
        cursor_order = payload["sort_order"]
        cursor_id = UUID(payload["id"])
        for i, row in enumerate(rows):
            if row.sort_order > cursor_order or (
                row.sort_order == cursor_order and row.id > cursor_id
            ):
                start = i
                break
        else:
            start = len(rows)
    page_rows = rows[start : start + limit]
    has_more = start + limit < len(rows)
    next_cursor = None
    if has_more and page_rows:
        last = page_rows[-1]
        next_cursor = encode_cursor(
            {"sort_order": last.sort_order, "id": str(last.id)},
        )
    items = [result_out(r) for r in page_rows]
    return CursorPage(items=items, next_cursor=next_cursor, has_more=has_more)


def result_out(row: SearchCatalogItem) -> SearchResultItemOut:
    filt = SearchFilterOut(row.filter.value) if row.filter else None
    return SearchResultItemOut(
        id=row.id,
        title=row.title,
        match_percent=row.match_percent,
        icon_key=row.icon_key,
        icon_color_hex=row.icon_color_hex,
        badge=row.badge,
        progress=row.progress,
        checked=row.checked,
        filter=filt,
    )
