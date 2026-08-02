from datetime import datetime
from enum import Enum
from uuid import UUID

from pydantic import BaseModel, Field


class ActivityTypeOut(str, Enum):
    jogging = "jogging"
    running = "running"
    cycling = "cycling"
    yoga = "yoga"
    weights = "weights"
    swimming = "swimming"
    basketball = "basketball"
    hiking = "hiking"
    hiit = "hiit"


class ActivityStatusItemOut(BaseModel):
    label: str
    hours_label: str
    color_hex: str
    rotation_deg: float
    width: float
    height: float
    dx: float
    dy: float


class ActivityStatusOut(BaseModel):
    items: list[ActivityStatusItemOut]
    has_activities: bool


class DirectionsOut(BaseModel):
    address: str
    instruction: str
    distance_left: str
    arrival_label: str
    thumbnail_url: str


class ActivityCreateRequest(BaseModel):
    type: ActivityTypeOut
    title: str | None = Field(default=None, max_length=255)


class ActivityOut(BaseModel):
    id: UUID
    type: ActivityTypeOut
    title: str | None
    started_at: datetime
    ended_at: datetime | None
    distance_m: float | None
    calories: int | None
    avg_bpm: int | None


class ActivityCompleteRequest(BaseModel):
    distance_m: float | None = Field(default=None, ge=0)
    calories: int | None = Field(default=None, ge=0)
    avg_bpm: int | None = Field(default=None, ge=30, le=250)


class DonutSegmentOut(BaseModel):
    label: str
    percent: int
    color_hex: str


class ActivityCompleteOut(BaseModel):
    activity: ActivityOut
    title: str
    segments: list[DonutSegmentOut]
    suggestion_title: str
    suggestion_subtitle: str
