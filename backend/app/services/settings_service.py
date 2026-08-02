from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException
from app.core.pagination import CursorPage
from app.models.settings import Notification, NotificationTrailing, UserSettings
from app.repositories.settings_repository import (
    NotificationRepository,
    UserSettingsRepository,
    notification_out,
)
from app.schemas.settings import (
    NotificationOut,
    NotificationPageOut,
    NotificationScopeOut,
    SettingsItemOut,
    SettingsOut,
    SettingsPatchRequest,
    SettingsSectionOut,
)


class SettingsService:
    def __init__(self) -> None:
        self.settings = UserSettingsRepository()
        self.notifications = NotificationRepository()

    async def _ensure_settings(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> UserSettings:
        row = await self.settings.get_for_user(session, user_id)
        if row is not None:
            return row
        return await self.settings.add(
            session,
            UserSettings(user_id=user_id, dark_mode=False, notifications_enabled=True),
        )

    async def ensure_notification_seed(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> None:
        if await self.notifications.count_for_user(session, user_id) > 0:
            return
        await self._seed_notifications(session, user_id)

    async def _seed_notifications(self, session: AsyncSession, user_id: UUID) -> None:
        now = datetime.now(UTC)
        past = now - timedelta(days=3)
        specs = self._notification_specs()
        for i, spec in enumerate(specs):
            await self.notifications.add(
                session,
                Notification(
                    user_id=user_id,
                    title=spec["title"],
                    subtitle=spec["subtitle"],
                    icon_key=spec["icon_key"],
                    color_hex=spec["color_hex"],
                    is_read=False,
                    trailing=spec["trailing"],
                    badge=spec.get("badge"),
                    progress=spec.get("progress"),
                    occurred_at=now if i < 3 else past,
                ),
            )

    def _notification_specs(self) -> list[dict]:
        return [
            {
                "title": "Unread AI Chatbot Messages",
                "subtitle": "8 new messages from Uplift.ai",
                "icon_key": "notifications",
                "color_hex": "#FFFFFF",
                "trailing": NotificationTrailing.badge,
                "badge": "4+",
            },
            {
                "title": "Score Increased",
                "subtitle": "Uplift Score is 87",
                "icon_key": "score",
                "color_hex": "#FF7A28",
                "trailing": NotificationTrailing.badge,
                "badge": "8+",
            },
            {
                "title": "Drink More Water",
                "subtitle": "You need to drink 1500ml left.",
                "icon_key": "water",
                "color_hex": "#2A66F6",
                "trailing": NotificationTrailing.progress,
                "progress": 0.35,
            },
            {
                "title": "Workout Complete",
                "subtitle": "Upper Body Set Completed",
                "icon_key": "dumbbell",
                "color_hex": "#88D317",
                "trailing": NotificationTrailing.check,
            },
            {
                "title": "Nutrition Upgrade",
                "subtitle": "Take 87g of protein!",
                "icon_key": "apple",
                "color_hex": "#A335F3",
                "trailing": NotificationTrailing.none,
            },
            {
                "title": "Fitness Data Ready!",
                "subtitle": "Here's fitness data for November",
                "icon_key": "data",
                "color_hex": "#F14C4C",
                "trailing": NotificationTrailing.none,
            },
        ]

    def _menu_sections(self) -> list[SettingsSectionOut]:
        return [
            SettingsSectionOut(
                title="General",
                items=[
                    SettingsItemOut(id="notification", label="Notification", icon_key="notifications"),
                    SettingsItemOut(id="personal", label="Personal Information", icon_key="person"),
                    SettingsItemOut(id="coach", label="Coach Contact", icon_key="phone"),
                    SettingsItemOut(id="dark_mode", label="Dark Mode", icon_key="flag", is_toggle=True),
                    SettingsItemOut(id="devices", label="Linked Devices", icon_key="watch"),
                ],
            ),
            SettingsSectionOut(
                title="Security & Privacy",
                items=[
                    SettingsItemOut(id="security", label="Main Security", icon_key="lock"),
                ],
            ),
        ]

    async def get_settings(self, session: AsyncSession, user_id: UUID) -> SettingsOut:
        prefs = await self._ensure_settings(session, user_id)
        return SettingsOut(
            sections=self._menu_sections(),
            dark_mode=prefs.dark_mode,
            notifications_enabled=prefs.notifications_enabled,
        )

    async def patch_settings(
        self,
        session: AsyncSession,
        user_id: UUID,
        body: SettingsPatchRequest,
    ) -> SettingsOut:
        prefs = await self._ensure_settings(session, user_id)
        if body.dark_mode is not None:
            prefs.dark_mode = body.dark_mode
        if body.notifications_enabled is not None:
            prefs.notifications_enabled = body.notifications_enabled
        await session.flush()
        return await self.get_settings(session, user_id)

    def _day_bounds(self, now: datetime) -> tuple[datetime, datetime]:
        start = datetime(now.year, now.month, now.day, tzinfo=UTC)
        return start, start + timedelta(days=1)

    async def list_notifications(
        self,
        session: AsyncSession,
        user_id: UUID,
        scope: NotificationScopeOut,
        cursor: str | None,
        limit: int,
    ) -> NotificationPageOut:
        await self.ensure_notification_seed(session, user_id)
        start, end = self._day_bounds(datetime.now(UTC))
        if scope == NotificationScopeOut.today:
            page = await self.notifications.list_by_scope_cursor(
                session, user_id, start, end, cursor, limit,
            )
        else:
            page = await self.notifications.list_by_scope_cursor(
                session, user_id, start, None, cursor, limit,
            )
        return NotificationPageOut(scope=scope, items=page)

    async def mark_read(
        self,
        session: AsyncSession,
        user_id: UUID,
        notification_id: UUID,
    ) -> NotificationOut:
        await self.ensure_notification_seed(session, user_id)
        row = await self.notifications.get_for_user(session, notification_id, user_id)
        if row is None:
            raise NotFoundException("Notification not found")
        row.is_read = True
        await session.flush()
        await session.refresh(row)
        return notification_out(row)
