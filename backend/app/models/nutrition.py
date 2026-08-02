import enum
from datetime import datetime
from uuid import UUID

from sqlalchemy import DateTime, Enum, Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin, UUIDMixin


class MealType(str, enum.Enum):
    breakfast = "breakfast"
    lunch = "lunch"
    dinner = "dinner"
    snack = "snack"


class MealEntryMethod(str, enum.Enum):
    manual = "manual"
    ai_scan = "ai_scan"


class Meal(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "meals"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
    )
    name: Mapped[str] = mapped_column(String(255))
    type: Mapped[MealType] = mapped_column(
        Enum(MealType, name="meal_type", native_enum=False),
    )
    protein_g: Mapped[float] = mapped_column(Float)
    carbs_g: Mapped[float] = mapped_column(Float)
    fat_g: Mapped[float] = mapped_column(Float)
    entry_method: Mapped[MealEntryMethod] = mapped_column(
        Enum(MealEntryMethod, name="meal_entry_method", native_enum=False),
    )
    image_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    logged_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
