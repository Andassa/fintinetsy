from datetime import datetime
from uuid import UUID

from sqlalchemy import DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin, UUIDMixin


class UserStatsGoals(TimestampMixin, Base):
    __tablename__ = "user_stats_goals"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    hydration_goal_ml: Mapped[int] = mapped_column(Integer, default=2000)
    calorie_goal_kcal: Mapped[int] = mapped_column(Integer, default=1903)


class HydrationLog(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "hydration_logs"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
    )
    value: Mapped[float] = mapped_column(Float)
    unit: Mapped[str] = mapped_column(String(16), default="ml")
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class HeartRateLog(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "heart_rate_logs"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
    )
    value: Mapped[float] = mapped_column(Float)
    unit: Mapped[str] = mapped_column(String(16), default="bpm")
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    activity_label: Mapped[str | None] = mapped_column(String(255), nullable=True)
    pressure: Mapped[int | None] = mapped_column(Integer, nullable=True)
    oxygen: Mapped[int | None] = mapped_column(Integer, nullable=True)


class CalorieLog(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "calorie_logs"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
    )
    value: Mapped[float] = mapped_column(Float)
    unit: Mapped[str] = mapped_column(String(16), default="kcal")
    recorded_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
