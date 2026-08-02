from datetime import datetime
from enum import Enum
from uuid import UUID

from pydantic import BaseModel

from app.core.pagination import CursorPage


class SettingsItemOut(BaseModel):
    id: str
    label: str
    icon_key: str
    is_toggle: bool = False


class SettingsSectionOut(BaseModel):
    title: str
    items: list[SettingsItemOut]


class SettingsOut(BaseModel):
    sections: list[SettingsSectionOut]
    dark_mode: bool
    notifications_enabled: bool


class SettingsPatchRequest(BaseModel):
    dark_mode: bool | None = None
    notifications_enabled: bool | None = None


class NotificationTrailingOut(str, Enum):
    none = "none"
    badge = "badge"
    progress = "progress"
    check = "check"


class NotificationScopeOut(str, Enum):
    today = "today"
    past = "past"


class NotificationOut(BaseModel):
    id: UUID
    title: str
    subtitle: str
    icon_key: str
    color_hex: str
    is_read: bool
    trailing: NotificationTrailingOut
    badge: str | None = None
    progress: float | None = None
    occurred_at: datetime


class NotificationPageOut(BaseModel):
    scope: NotificationScopeOut
    items: CursorPage[NotificationOut]
