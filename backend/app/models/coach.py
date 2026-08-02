import enum
from datetime import datetime
from uuid import UUID

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base, TimestampMixin, UUIDMixin


class ConversationTab(str, enum.Enum):
    ai = "ai"
    archived = "archived"
    deleted = "deleted"


class MessageKind(str, enum.Enum):
    bot = "bot"
    user = "user"
    user_suggestion = "user_suggestion"
    bot_card = "bot_card"


class CoachConversation(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "coach_conversations"

    user_id: Mapped[UUID] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
    )
    title: Mapped[str] = mapped_column(String(255))
    model: Mapped[str] = mapped_column(String(64), default="Gpt4.0")
    tab: Mapped[ConversationTab] = mapped_column(
        Enum(ConversationTab, name="conversation_tab", native_enum=False),
        default=ConversationTab.ai,
        index=True,
    )
    subtitle: Mapped[str] = mapped_column(String(255), default="")
    icon_key: Mapped[str] = mapped_column(String(64), default="notifications")
    color_hex: Mapped[str] = mapped_column(String(16), default="#FFFFFF")
    badge: Mapped[str | None] = mapped_column(String(16), nullable=True)
    total_label: Mapped[str] = mapped_column(String(64), default="")
    sort_order: Mapped[int] = mapped_column(Integer, default=0)

    messages: Mapped[list["CoachMessage"]] = relationship(
        back_populates="conversation",
        cascade="all, delete-orphan",
    )


class CoachMessage(UUIDMixin, TimestampMixin, Base):
    __tablename__ = "coach_messages"

    conversation_id: Mapped[UUID] = mapped_column(
        ForeignKey("coach_conversations.id", ondelete="CASCADE"),
        index=True,
    )
    kind: Mapped[MessageKind] = mapped_column(
        Enum(MessageKind, name="message_kind", native_enum=False),
    )
    text: Mapped[str] = mapped_column(Text, default="")
    selected: Mapped[bool] = mapped_column(Boolean, default=False)
    card_title: Mapped[str | None] = mapped_column(String(255), nullable=True)
    card_subtitle: Mapped[str | None] = mapped_column(String(255), nullable=True)
    tags_csv: Mapped[str | None] = mapped_column(String(512), nullable=True)
    sent_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))

    conversation: Mapped[CoachConversation] = relationship(back_populates="messages")
