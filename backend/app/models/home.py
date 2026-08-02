from sqlalchemy import Boolean, Float, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin, UUIDMixin


class HomeCategory(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "home_categories"

    code: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    label: Mapped[str] = mapped_column(String(120))
    icon_key: Mapped[str] = mapped_column(String(64))
    sort_order: Mapped[int] = mapped_column(Integer, default=0)
    is_default_selected: Mapped[bool] = mapped_column(Boolean, default=False)


class HomeFeaturedWorkout(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "home_featured_workouts"

    code: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    title: Mapped[str] = mapped_column(String(255))
    subtitle: Mapped[str] = mapped_column(String(255))
    duration_minutes: Mapped[int] = mapped_column(Integer)
    calories: Mapped[int] = mapped_column(Integer)
    image_url: Mapped[str] = mapped_column(String(512))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class HomeFeaturedMeal(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "home_featured_meals"

    code: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    title: Mapped[str] = mapped_column(String(255))
    calories: Mapped[int] = mapped_column(Integer)
    duration_minutes: Mapped[int] = mapped_column(Integer)
    protein_g: Mapped[int] = mapped_column(Integer)
    fats_g: Mapped[int] = mapped_column(Integer)
    image_url: Mapped[str] = mapped_column(String(512))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class HomeActivityBlobLayout(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "home_activity_blob_layouts"

    hours_label: Mapped[str] = mapped_column(String(32))
    color_hex: Mapped[str] = mapped_column(String(16))
    rotation_deg: Mapped[float] = mapped_column(Float)
    width_factor: Mapped[float] = mapped_column(Float)
    height_factor: Mapped[float] = mapped_column(Float)
    align_x: Mapped[float] = mapped_column(Float)
    align_y: Mapped[float] = mapped_column(Float)
    sort_order: Mapped[int] = mapped_column(Integer, default=0)


class HomeAiCoachCardSeed(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "home_ai_coach_card"

    conversations_count: Mapped[int] = mapped_column(Integer, default=1879)
    subtitle: Mapped[str] = mapped_column(String(255))
    image_url: Mapped[str] = mapped_column(String(512))
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
