from datetime import datetime
from enum import Enum
from uuid import UUID

from pydantic import BaseModel, Field

from app.core.pagination import CursorPage


class ConversationTabOut(str, Enum):
    ai = "ai"
    archived = "archived"
    deleted = "deleted"


class MessageKindOut(str, Enum):
    bot = "bot"
    user = "user"
    user_suggestion = "user_suggestion"
    bot_card = "bot_card"


class CoachConversationPreviewOut(BaseModel):
    id: UUID
    title: str
    model: str
    total_label: str
    icon_key: str
    color_hex: str


class CoachHubOut(BaseModel):
    total_conversations: str
    total_label: str
    model_label: str
    conversations: list[CoachConversationPreviewOut]
    pro_title: str
    pro_benefits: list[str]


class AiChatListItemOut(BaseModel):
    id: UUID
    title: str
    subtitle: str
    icon_key: str
    color_hex: str
    badge: str | None = None


class ChatMessageOut(BaseModel):
    id: UUID
    kind: MessageKindOut
    text: str
    selected: bool = False
    card_title: str | None = None
    card_subtitle: str | None = None
    tags: list[str] | None = None
    sent_at: datetime


class AiChatThreadOut(BaseModel):
    chat_id: UUID
    bot_name: str
    status: str
    timestamp: str
    messages: CursorPage[ChatMessageOut]


class SendMessageRequest(BaseModel):
    text: str = Field(min_length=1, max_length=4000)
