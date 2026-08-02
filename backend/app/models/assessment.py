import enum
from uuid import UUID

from sqlalchemy import Boolean, Enum, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin, UUIDMixin


class WeightUnit(str, enum.Enum):
    kg = "kg"
    lbs = "lbs"


class GenderOption(str, enum.Enum):
    male = "male"
    female = "female"
    skipped = "skipped"


class FitnessGoal(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "fitness_goals"

    code: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    label: Mapped[str] = mapped_column(String(255))
    icon_key: Mapped[str] = mapped_column(String(64))


class AssessmentProfile(TimestampMixin, Base):
    __tablename__ = "assessment_profiles"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    age: Mapped[int | None] = mapped_column(Integer, nullable=True)
    weight_kg: Mapped[float | None] = mapped_column(Float, nullable=True)
    weight_unit: Mapped[WeightUnit] = mapped_column(
        Enum(WeightUnit, name="weight_unit_enum", native_enum=False),
        default=WeightUnit.kg,
        nullable=False,
    )
    fitness_level: Mapped[int] = mapped_column(Integer, default=3)
    gender: Mapped[GenderOption | None] = mapped_column(
        Enum(GenderOption, name="gender_option_enum", native_enum=False),
        nullable=True,
    )
    goal_code: Mapped[str | None] = mapped_column(
        String(64),
        ForeignKey("fitness_goals.code", ondelete="SET NULL"),
        nullable=True,
    )
    avatar_id: Mapped[str | None] = mapped_column(String(64), nullable=True)
    vocal_completed: Mapped[bool] = mapped_column(Boolean, default=False)

    goal: Mapped[FitnessGoal | None] = relationship()


class AssessmentConfigRow(UUIDMixin, TimestampMixin, Base):
    """Singleton-ish config row for assessment ranges and vocal copy."""

    __tablename__ = "assessment_config"

    min_age: Mapped[int] = mapped_column(Integer, default=12)
    max_age: Mapped[int] = mapped_column(Integer, default=80)
    default_age: Mapped[int] = mapped_column(Integer, default=19)
    min_weight_kg: Mapped[float] = mapped_column(Float, default=30.0)
    max_weight_kg: Mapped[float] = mapped_column(Float, default=180.0)
    default_weight_kg: Mapped[float] = mapped_column(Float, default=62.0)
    fitness_labels_csv: Mapped[str] = mapped_column(
        Text,
        default="Beginner,Novice,Somewhat Athletic,Athletic,Very Athletic,Elite",
    )
    vocal_prompt: Mapped[str] = mapped_column(Text)
    vocal_highlighted_words: Mapped[str] = mapped_column(String(255))
    vocal_subtitle: Mapped[str] = mapped_column(Text)
