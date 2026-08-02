import enum
from datetime import datetime
from uuid import UUID

from sqlalchemy import DateTime, Enum, Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin, UUIDMixin


class ActivityType(str, enum.Enum):
    jogging = "jogging"
    running = "running"
    cycling = "cycling"
    yoga = "yoga"
    weights = "weights"
    swimming = "swimming"
    basketball = "basketball"
    hiking = "hiking"
    hiit = "hiit"


class Activity(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "activities"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
    )
    type: Mapped[ActivityType] = mapped_column(
        Enum(ActivityType, name="activity_type", native_enum=False),
    )
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    ended_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    distance_m: Mapped[float | None] = mapped_column(Float, nullable=True)
    calories: Mapped[int | None] = mapped_column(Integer, nullable=True)
    avg_bpm: Mapped[int | None] = mapped_column(Integer, nullable=True)
    title: Mapped[str | None] = mapped_column(String(255), nullable=True)
