import enum
from datetime import datetime
from uuid import UUID

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin, UUIDMixin


class Membership(str, enum.Enum):
    basic = "basic"
    pro = "pro"


class User(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(String(320), unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(String(255))
    name: Mapped[str] = mapped_column(String(120))
    avatar_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    membership: Mapped[Membership] = mapped_column(
        Enum(Membership, name="membership_enum", native_enum=False),
        default=Membership.basic,
        nullable=False,
    )

    refresh_tokens: Mapped[list["RefreshToken"]] = relationship(
        back_populates="user",
        cascade="all, delete-orphan",
    )
    reset_requests: Mapped[list["PasswordResetRequest"]] = relationship(
        back_populates="user",
        cascade="all, delete-orphan",
    )


class RefreshToken(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "refresh_tokens"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
    )
    token_hash: Mapped[str] = mapped_column(String(64), unique=True, index=True)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    revoked: Mapped[bool] = mapped_column(Boolean, default=False)

    user: Mapped[User] = relationship(back_populates="refresh_tokens")


class ResetMethod(str, enum.Enum):
    email = "email"
    two_factor = "two_factor"
    google_auth = "google_auth"


class PasswordResetRequest(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "password_reset_requests"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
    )
    method: Mapped[ResetMethod] = mapped_column(
        Enum(ResetMethod, name="reset_method_enum", native_enum=False),
    )
    sent_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    consumed: Mapped[bool] = mapped_column(Boolean, default=False)

    user: Mapped[User] = relationship(back_populates="reset_requests")
