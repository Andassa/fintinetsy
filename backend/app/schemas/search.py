from enum import Enum
from uuid import UUID

from pydantic import BaseModel

from app.core.pagination import CursorPage


class SearchFilterOut(str, Enum):
    workout = "workout"
    meals = "meals"
    community = "community"


class SearchSuggestionOut(BaseModel):
    id: UUID
    label: str


class SearchResultItemOut(BaseModel):
    id: UUID
    title: str
    match_percent: int
    icon_key: str
    icon_color_hex: str
    badge: str | None = None
    progress: float | None = None
    checked: bool = False
    filter: SearchFilterOut | None = None


class SearchPageOut(BaseModel):
    items: CursorPage[SearchResultItemOut]
    filters: list[SearchFilterOut]
    query: str = ""
