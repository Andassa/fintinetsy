from datetime import datetime
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.pagination import CursorPage, decode_cursor, encode_cursor
from app.models.coach import CoachConversation, CoachMessage, ConversationTab
from app.repositories.base import GenericRepository
from app.schemas.coach import AiChatListItemOut, ChatMessageOut, MessageKindOut


class CoachConversationRepository(GenericRepository[CoachConversation]):
    def __init__(self) -> None:
        super().__init__(CoachConversation)

    async def count_for_user(self, session: AsyncSession, user_id: UUID) -> int:
        result = await session.execute(
            select(func.count()).select_from(CoachConversation).where(
                CoachConversation.user_id == user_id,
            ),
        )
        return int(result.scalar_one())

    async def list_hub_previews(
        self,
        session: AsyncSession,
        user_id: UUID,
        limit: int = 2,
    ) -> list[CoachConversation]:
        result = await session.execute(
            select(CoachConversation)
            .where(
                CoachConversation.user_id == user_id,
                CoachConversation.tab == ConversationTab.ai,
            )
            .order_by(CoachConversation.sort_order.asc())
            .limit(limit),
        )
        return list(result.scalars().all())

    async def get_for_user(
        self,
        session: AsyncSession,
        chat_id: UUID,
        user_id: UUID,
    ) -> CoachConversation | None:
        result = await session.execute(
            select(CoachConversation).where(
                CoachConversation.id == chat_id,
                CoachConversation.user_id == user_id,
            ),
        )
        return result.scalar_one_or_none()

    async def list_by_tab_cursor(
        self,
        session: AsyncSession,
        user_id: UUID,
        tab: ConversationTab,
        cursor: str | None,
        limit: int,
    ) -> CursorPage[AiChatListItemOut]:
        stmt = (
            select(CoachConversation)
            .where(
                CoachConversation.user_id == user_id,
                CoachConversation.tab == tab,
            )
            .order_by(CoachConversation.sort_order.asc(), CoachConversation.id.asc())
        )
        payload = decode_cursor(cursor)
        if payload and "sort_order" in payload and "id" in payload:
            stmt = stmt.where(
                (CoachConversation.sort_order > payload["sort_order"])
                | (
                    (CoachConversation.sort_order == payload["sort_order"])
                    & (CoachConversation.id > UUID(payload["id"]))
                ),
            )
        rows = list((await session.execute(stmt.limit(limit + 1))).scalars().all())
        has_more = len(rows) > limit
        page = rows[:limit]
        next_cursor = None
        if has_more and page:
            last = page[-1]
            next_cursor = encode_cursor(
                {"sort_order": last.sort_order, "id": str(last.id)},
            )
        items = [
            AiChatListItemOut(
                id=c.id,
                title=c.title,
                subtitle=c.subtitle,
                icon_key=c.icon_key,
                color_hex=c.color_hex,
                badge=c.badge,
            )
            for c in page
        ]
        return CursorPage(items=items, next_cursor=next_cursor, has_more=has_more)


class CoachMessageRepository(GenericRepository[CoachMessage]):
    def __init__(self) -> None:
        super().__init__(CoachMessage)

    async def list_by_chat_cursor(
        self,
        session: AsyncSession,
        conversation_id: UUID,
        user_id: UUID,
        cursor: str | None,
        limit: int,
    ) -> CursorPage[ChatMessageOut]:
        stmt = (
            select(CoachMessage)
            .join(
                CoachConversation,
                CoachMessage.conversation_id == CoachConversation.id,
            )
            .where(
                CoachMessage.conversation_id == conversation_id,
                CoachConversation.user_id == user_id,
            )
            .order_by(CoachMessage.sent_at.asc(), CoachMessage.id.asc())
        )
        payload = decode_cursor(cursor)
        if payload and "sent_at" in payload and "id" in payload:
            sent_at = datetime.fromisoformat(payload["sent_at"])
            stmt = stmt.where(
                (CoachMessage.sent_at > sent_at)
                | (
                    (CoachMessage.sent_at == sent_at)
                    & (CoachMessage.id > UUID(payload["id"]))
                ),
            )
        rows = list((await session.execute(stmt.limit(limit + 1))).scalars().all())
        has_more = len(rows) > limit
        page = rows[:limit]
        next_cursor = None
        if has_more and page:
            last = page[-1]
            next_cursor = encode_cursor(
                {"sent_at": last.sent_at.isoformat(), "id": str(last.id)},
            )
        items = [message_out(m) for m in page]
        return CursorPage(items=items, next_cursor=next_cursor, has_more=has_more)


def message_out(message: CoachMessage) -> ChatMessageOut:
    tags = None
    if message.tags_csv:
        tags = [t for t in message.tags_csv.split(",") if t]
    return ChatMessageOut(
        id=message.id,
        kind=MessageKindOut(message.kind.value),
        text=message.text,
        selected=message.selected,
        card_title=message.card_title,
        card_subtitle=message.card_subtitle,
        tags=tags,
        sent_at=message.sent_at,
    )
