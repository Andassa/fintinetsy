from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException
from app.core.pagination import CursorPage
from app.models.coach import (
    CoachConversation,
    CoachMessage,
    ConversationTab,
    MessageKind,
)
from app.repositories.coach_repository import (
    CoachConversationRepository,
    CoachMessageRepository,
    message_out,
)
from app.schemas.coach import (
    AiChatListItemOut,
    AiChatThreadOut,
    ChatMessageOut,
    CoachConversationPreviewOut,
    CoachHubOut,
    ConversationTabOut,
    SendMessageRequest,
)


class CoachService:
    def __init__(self) -> None:
        self.conversations = CoachConversationRepository()
        self.messages = CoachMessageRepository()

    async def ensure_user_seed(self, session: AsyncSession, user_id: UUID) -> None:
        if await self.conversations.count_for_user(session, user_id) > 0:
            return
        await self._seed_conversations(session, user_id)

    async def _seed_conversations(self, session: AsyncSession, user_id: UUID) -> None:
        specs = self._chat_specs()
        now = datetime.now(UTC)
        for i, spec in enumerate(specs):
            chat = await self.conversations.add(
                session,
                CoachConversation(
                    user_id=user_id,
                    title=spec["title"],
                    model="Gpt4.0",
                    tab=ConversationTab.ai,
                    subtitle=spec["subtitle"],
                    icon_key=spec["icon_key"],
                    color_hex=spec["color_hex"],
                    badge=spec.get("badge"),
                    total_label=spec.get("total_label", ""),
                    sort_order=i,
                ),
            )
            if i == 0:
                await self._seed_thread_messages(session, chat.id, now)

    def _chat_specs(self) -> list[dict]:
        return [
            {
                "title": "How to bulk faster?",
                "subtitle": "8 new messages from Uplift.ai",
                "icon_key": "notifications",
                "color_hex": "#FFFFFF",
                "badge": "4+",
                "total_label": "456 Total",
            },
            {
                "title": "Should i Meditate?",
                "subtitle": "Uplift Score is 87",
                "icon_key": "score",
                "color_hex": "#FF7A00",
                "total_label": "45 Total",
            },
            {
                "title": "How much water daily?",
                "subtitle": "You need to drink 1500ml left.",
                "icon_key": "water",
                "color_hex": "#2A66F6",
            },
            {
                "title": "Gaining muscle fast",
                "subtitle": "Upper Body Set Completed",
                "icon_key": "dumbbell",
                "color_hex": "#88D317",
            },
            {
                "title": "Nutrition Upgrade",
                "subtitle": "Take 87g of protein!",
                "icon_key": "apple",
                "color_hex": "#A335F3",
            },
            {
                "title": "Fitness Data Ready!",
                "subtitle": "Here's fitness data for November",
                "icon_key": "data",
                "color_hex": "#F14C4C",
            },
        ]

    async def _seed_thread_messages(
        self,
        session: AsyncSession,
        chat_id: UUID,
        now: datetime,
    ) -> None:
        seeds = [
            (MessageKind.bot, "Hello, I'm Uplift! I'm your personal sport assistant.", False, None, None, None),
            (MessageKind.user_suggestion, "Book me a visit in a gym", False, None, None, None),
            (MessageKind.user_suggestion, "Show me other sports facilities around", False, None, None, None),
            (MessageKind.user_suggestion, "Show me other options", True, None, None, None),
            (MessageKind.bot, "Ok, how about these?", False, None, None, None),
            (
                MessageKind.bot_card,
                "",
                False,
                "BodyWorks on Nadwislanska 12 street",
                "250 meters • 30 zl/one entrance all day",
                "Gym,SPA,Pool",
            ),
        ]
        for kind, text, selected, card_title, card_subtitle, tags in seeds:
            await self.messages.add(
                session,
                CoachMessage(
                    conversation_id=chat_id,
                    kind=kind,
                    text=text,
                    selected=selected,
                    card_title=card_title,
                    card_subtitle=card_subtitle,
                    tags_csv=tags,
                    sent_at=now,
                ),
            )

    async def get_hub(self, session: AsyncSession, user_id: UUID) -> CoachHubOut:
        await self.ensure_user_seed(session, user_id)
        previews = await self.conversations.list_hub_previews(session, user_id)
        return CoachHubOut(
            total_conversations="9,781",
            total_label="245total",
            model_label="Gpt4.0",
            conversations=[
                CoachConversationPreviewOut(
                    id=c.id,
                    title=c.title,
                    model=c.model,
                    total_label=c.total_label or "0 Total",
                    icon_key=c.icon_key,
                    color_hex=c.color_hex,
                )
                for c in previews
            ],
            pro_title="Go Pro, Now!",
            pro_benefits=["Weekend Cheat", "Fast Growth"],
        )

    async def list_chats(
        self,
        session: AsyncSession,
        user_id: UUID,
        tab: ConversationTabOut,
        cursor: str | None,
        limit: int,
    ) -> CursorPage[AiChatListItemOut]:
        await self.ensure_user_seed(session, user_id)
        return await self.conversations.list_by_tab_cursor(
            session,
            user_id,
            ConversationTab(tab.value),
            cursor,
            limit,
        )

    async def get_messages(
        self,
        session: AsyncSession,
        user_id: UUID,
        chat_id: UUID,
        cursor: str | None,
        limit: int,
    ) -> AiChatThreadOut:
        await self.ensure_user_seed(session, user_id)
        chat = await self.conversations.get_for_user(session, chat_id, user_id)
        if chat is None:
            raise NotFoundException("Chat not found")
        page = await self.messages.list_by_chat_cursor(
            session,
            chat_id,
            user_id,
            cursor,
            limit,
        )
        return AiChatThreadOut(
            chat_id=chat.id,
            bot_name="Uplift",
            status="Always active",
            timestamp="Wed 8:21 AM",
            messages=page,
        )

    async def send_message(
        self,
        session: AsyncSession,
        user_id: UUID,
        chat_id: UUID,
        body: SendMessageRequest,
    ) -> ChatMessageOut:
        await self.ensure_user_seed(session, user_id)
        chat = await self.conversations.get_for_user(session, chat_id, user_id)
        if chat is None:
            raise NotFoundException("Chat not found")
        now = datetime.now(UTC)
        user_msg = await self.messages.add(
            session,
            CoachMessage(
                conversation_id=chat.id,
                kind=MessageKind.user,
                text=body.text.strip(),
                sent_at=now,
            ),
        )
        await self.messages.add(
            session,
            CoachMessage(
                conversation_id=chat.id,
                kind=MessageKind.bot,
                text="Ok, I can help with that.",
                sent_at=now,
            ),
        )
        chat.subtitle = body.text.strip()[:80]
        await session.flush()
        return message_out(user_msg)
