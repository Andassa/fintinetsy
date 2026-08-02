import enum
from datetime import datetime
from uuid import UUID

from sqlalchemy import Boolean, DateTime, Enum, Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base, TimestampMixin, UUIDMixin


class NotificationTrailing(str, enum.Enum):
    none = "none"
    badge = "badge"
    progress = "progress"
    check = "check"


class UserSettings(TimestampMixin, Base):
    __tablename__ = "user_settings"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    dark_mode: Mapped[bool] = mapped_column(Boolean, default=False)
    notifications_enabled: Mapped[bool] = mapped_column(Boolean, default=True)


class Notification(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "notifications"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
    )
    title: Mapped[str] = mapped_column(String(255))
    subtitle: Mapped[str] = mapped_column(String(255))
    icon_key: Mapped[str] = mapped_column(String(64))
    color_hex: Mapped[str] = mapped_column(String(16))
    is_read: Mapped[bool] = mapped_column(Boolean, default=False)
    trailing: Mapped[NotificationTrailing] = mapped_column(
        Enum(NotificationTrailing, name="notification_trailing", native_enum=False),
        default=NotificationTrailing.none,
    )
    badge: Mapped[str | None] = mapped_column(String(16), nullable=True)
    progress: Mapped[float | None] = mapped_column(Float, nullable=True)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
