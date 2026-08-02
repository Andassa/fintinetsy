from sqlalchemy.ext.asyncio import AsyncSession

from app.models.search import SearchCatalogItem, SearchFilterKind, SearchItemKind
from app.repositories.search_repository import (
    SearchCatalogRepository,
    filter_results,
    paginate_results,
)
from app.schemas.search import (
    SearchFilterOut,
    SearchPageOut,
    SearchSuggestionOut,
)


class SearchService:
    def __init__(self) -> None:
        self.catalog = SearchCatalogRepository()

    async def ensure_seed_data(self, session: AsyncSession) -> None:
        if await self.catalog.count_all(session) > 0:
            return
        await self._seed(session)

    async def _seed(self, session: AsyncSession) -> None:
        for i, label in enumerate(self._suggestion_labels()):
            await self.catalog.add(
                session,
                SearchCatalogItem(
                    code=f"sug_{i + 1}",
                    title=label,
                    kind=SearchItemKind.suggestion,
                    sort_order=i,
                ),
            )
        for i, spec in enumerate(self._result_specs()):
            await self.catalog.add(
                session,
                SearchCatalogItem(
                    code=f"res_{i + 1}",
                    title=spec["title"],
                    kind=SearchItemKind.result,
                    filter=spec["filter"],
                    match_percent=spec["match_percent"],
                    icon_key=spec["icon_key"],
                    icon_color_hex=spec["icon_color_hex"],
                    badge=spec.get("badge"),
                    progress=spec.get("progress"),
                    checked=spec.get("checked", False),
                    sort_order=i,
                ),
            )

    def _suggestion_labels(self) -> list[str]:
        return [
            "Fitness",
            "My Fitness Schedule",
            "Fitness Ai Assistant",
            "Visual AI Coach",
            "AR/VR Fitness Videos",
            "Fitness App",
        ]

    def _result_specs(self) -> list[dict]:
        return [
            {
                "title": "Virtual AI Coach",
                "filter": SearchFilterKind.community,
                "match_percent": 98,
                "icon_key": "notifications",
                "icon_color_hex": "#FFFFFF",
                "badge": "4+",
            },
            {
                "title": "Activity Tracker",
                "filter": SearchFilterKind.workout,
                "match_percent": 78,
                "icon_key": "directions_run",
                "icon_color_hex": "#FF7A21",
                "badge": "8+",
            },
            {
                "title": "Coach Farness",
                "filter": SearchFilterKind.community,
                "match_percent": 67,
                "icon_key": "chat_bubble",
                "icon_color_hex": "#2F69FF",
                "progress": 0.6,
            },
            {
                "title": "AI Fitness Assisstant",
                "filter": SearchFilterKind.workout,
                "match_percent": 82,
                "icon_key": "fitness_center",
                "icon_color_hex": "#8CC622",
                "checked": True,
            },
            {
                "title": "Workout Course",
                "filter": SearchFilterKind.workout,
                "match_percent": 55,
                "icon_key": "play_arrow",
                "icon_color_hex": "#8A2BE2",
            },
            {
                "title": "AI Workout",
                "filter": SearchFilterKind.meals,
                "match_percent": 48,
                "icon_key": "cloud",
                "icon_color_hex": "#FF4B4B",
            },
        ]

    async def suggestions(
        self,
        session: AsyncSession,
        query: str,
    ) -> list[SearchSuggestionOut]:
        await self.ensure_seed_data(session)
        return await self.catalog.list_suggestions(session, query)

    async def search(
        self,
        session: AsyncSession,
        query: str,
        filter_value: SearchFilterOut | None,
        cursor: str | None,
        limit: int,
    ) -> SearchPageOut:
        await self.ensure_seed_data(session)
        kind = SearchFilterKind(filter_value.value) if filter_value else None
        rows = await self.catalog.list_results(session, kind)
        filtered = filter_results(rows, query)
        page = paginate_results(filtered, cursor, limit)
        return SearchPageOut(
            items=page,
            filters=list(SearchFilterOut),
            query=query,
        )
