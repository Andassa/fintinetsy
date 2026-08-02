from datetime import datetime
from uuid import UUID

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin, UUIDMixin


class WorkoutCategory(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "workout_categories"

    code: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    title: Mapped[str] = mapped_column(String(120))
    description: Mapped[str] = mapped_column(Text)
    header_image_url: Mapped[str] = mapped_column(String(512))
    sort_order: Mapped[int] = mapped_column(Integer, default=0)

    workouts: Mapped[list["Workout"]] = relationship(back_populates="category")


class Workout(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "workouts"

    category_id: Mapped[UUID] = mapped_column(
        ForeignKey("workout_categories.id", ondelete="CASCADE"),
        index=True,
    )
    code: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    title: Mapped[str] = mapped_column(String(255))
    coach_label: Mapped[str] = mapped_column(String(255))
    duration_minutes: Mapped[int] = mapped_column(Integer)
    calories: Mapped[int] = mapped_column(Integer)
    sets: Mapped[int] = mapped_column(Integer)
    reps: Mapped[int] = mapped_column(Integer)
    total_exercises: Mapped[int] = mapped_column(Integer, default=10)
    hero_image_url: Mapped[str] = mapped_column(String(512))
    thumbnail_url: Mapped[str] = mapped_column(String(512))
    sort_order: Mapped[int] = mapped_column(Integer, default=0)

    category: Mapped[WorkoutCategory] = relationship(back_populates="workouts")
    sessions: Mapped[list["WorkoutSession"]] = relationship(back_populates="workout")


class WorkoutBrowseSeed(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "workout_browse_pages"

    title: Mapped[str] = mapped_column(String(255))
    subtitle: Mapped[str] = mapped_column(Text)
    hero_image_url: Mapped[str] = mapped_column(String(512))
    active_dot_index: Mapped[int] = mapped_column(Integer, default=1)
    dot_count: Mapped[int] = mapped_column(Integer, default=3)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class WorkoutSession(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "workout_sessions"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
    )
    workout_id: Mapped[UUID] = mapped_column(
        ForeignKey("workouts.id", ondelete="CASCADE"),
        index=True,
    )
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    completed_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    calories_burned: Mapped[int | None] = mapped_column(Integer, nullable=True)
    duration_minutes: Mapped[int | None] = mapped_column(Integer, nullable=True)
    avg_bpm: Mapped[int | None] = mapped_column(Integer, nullable=True)

    workout: Mapped[Workout] = relationship(back_populates="sessions")
