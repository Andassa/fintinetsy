import enum

from sqlalchemy import Boolean, Enum, Float, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin, UUIDMixin


class SearchFilterKind(str, enum.Enum):
    workout = "workout"
    meals = "meals"
    community = "community"


class SearchItemKind(str, enum.Enum):
    suggestion = "suggestion"
    result = "result"


class SearchCatalogItem(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "search_catalog_items"

    code: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    title: Mapped[str] = mapped_column(String(255))
    kind: Mapped[SearchItemKind] = mapped_column(
        Enum(SearchItemKind, name="search_item_kind", native_enum=False),
    )
    filter: Mapped[SearchFilterKind | None] = mapped_column(
        Enum(SearchFilterKind, name="search_filter_kind", native_enum=False),
        nullable=True,
    )
    match_percent: Mapped[int] = mapped_column(Integer, default=0)
    icon_key: Mapped[str] = mapped_column(String(64), default="search")
    icon_color_hex: Mapped[str] = mapped_column(String(16), default="#FFFFFF")
    badge: Mapped[str | None] = mapped_column(String(16), nullable=True)
    progress: Mapped[float | None] = mapped_column(Float, nullable=True)
    checked: Mapped[bool] = mapped_column(Boolean, default=False)
    sort_order: Mapped[int] = mapped_column(Integer, default=0)
