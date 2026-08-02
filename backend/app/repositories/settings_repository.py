from datetime import datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.pagination import CursorPage, decode_cursor, encode_cursor
from app.models.settings import Notification, UserSettings
from app.repositories.base import GenericRepository
from app.schemas.settings import NotificationOut, NotificationTrailingOut


class UserSettingsRepository(GenericRepository[UserSettings]):
    def __init__(self) -> None:
        super().__init__(UserSettings)

    async def get_for_user(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> UserSettings | None:
        return await session.get(UserSettings, user_id)


class NotificationRepository(GenericRepository[Notification]):
    def __init__(self) -> None:
        super().__init__(Notification)

    async def count_for_user(self, session: AsyncSession, user_id: UUID) -> int:
        result = await session.execute(
            select(Notification.id).where(Notification.user_id == user_id).limit(1),
        )
        return 1 if result.scalar_one_or_none() is not None else 0

    async def get_for_user(
        self,
        session: AsyncSession,
        notification_id: UUID,
        user_id: UUID,
    ) -> Notification | None:
        result = await session.execute(
            select(Notification).where(
                Notification.id == notification_id,
                Notification.user_id == user_id,
            ),
        )
        return result.scalar_one_or_none()

    async def list_by_scope_cursor(
        self,
        session: AsyncSession,
        user_id: UUID,
        start: datetime,
        end: datetime | None,
        cursor: str | None,
        limit: int,
    ) -> CursorPage[NotificationOut]:
        stmt = select(Notification).where(Notification.user_id == user_id)
        if end is None:
            stmt = stmt.where(Notification.occurred_at < start)
        else:
            stmt = stmt.where(
                Notification.occurred_at >= start,
                Notification.occurred_at < end,
            )
        stmt = stmt.order_by(Notification.occurred_at.desc(), Notification.id.desc())
        payload = decode_cursor(cursor)
        if payload and "occurred_at" in payload and "id" in payload:
            occurred = datetime.fromisoformat(payload["occurred_at"])
            stmt = stmt.where(
                (Notification.occurred_at < occurred)
                | (
                    (Notification.occurred_at == occurred)
                    & (Notification.id < UUID(payload["id"]))
                ),
            )
        rows = list((await session.execute(stmt.limit(limit + 1))).scalars().all())
        has_more = len(rows) > limit
        page = rows[:limit]
        next_cursor = None
        if has_more and page:
            last = page[-1]
            next_cursor = encode_cursor(
                {"occurred_at": last.occurred_at.isoformat(), "id": str(last.id)},
            )
        items = [notification_out(n) for n in page]
        return CursorPage(items=items, next_cursor=next_cursor, has_more=has_more)


def notification_out(row: Notification) -> NotificationOut:
    return NotificationOut(
        id=row.id,
        title=row.title,
        subtitle=row.subtitle,
        icon_key=row.icon_key,
        color_hex=row.color_hex,
        is_read=row.is_read,
        trailing=NotificationTrailingOut(row.trailing.value),
        badge=row.badge,
        progress=row.progress,
        occurred_at=row.occurred_at,
    )
