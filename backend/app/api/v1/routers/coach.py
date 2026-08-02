from uuid import UUID

from fastapi import APIRouter, status

from app.core.dependencies import CurrentUser, DbSession
from app.core.pagination import CursorPage, CursorQuery, LimitQuery, MessageLimitQuery
from app.schemas.coach import (
    AiChatListItemOut,
    AiChatThreadOut,
    ChatMessageOut,
    CoachHubOut,
    ConversationTabOut,
    SendMessageRequest,
)
from app.services.coach_service import CoachService

router = APIRouter(prefix="/coach", tags=["coach"])
_service = CoachService()


@router.get("/hub", response_model=CoachHubOut)
async def get_coach_hub(session: DbSession, user: CurrentUser) -> CoachHubOut:
    return await _service.get_hub(session, user.id)


@router.get("/chats", response_model=CursorPage[AiChatListItemOut])
async def list_chats(
    session: DbSession,
    user: CurrentUser,
    tab: ConversationTabOut = ConversationTabOut.ai,
    cursor: CursorQuery = None,
    limit: LimitQuery = 20,
) -> CursorPage[AiChatListItemOut]:
    return await _service.list_chats(session, user.id, tab, cursor, limit)


@router.get("/chats/{chat_id}/messages", response_model=AiChatThreadOut)
async def get_chat_messages(
    chat_id: UUID,
    session: DbSession,
    user: CurrentUser,
    cursor: CursorQuery = None,
    limit: MessageLimitQuery = 50,
) -> AiChatThreadOut:
    return await _service.get_messages(session, user.id, chat_id, cursor, limit)


@router.post(
    "/chats/{chat_id}/messages",
    response_model=ChatMessageOut,
    status_code=status.HTTP_201_CREATED,
)
async def send_chat_message(
    chat_id: UUID,
    body: SendMessageRequest,
    session: DbSession,
    user: CurrentUser,
) -> ChatMessageOut:
    return await _service.send_message(session, user.id, chat_id, body)
