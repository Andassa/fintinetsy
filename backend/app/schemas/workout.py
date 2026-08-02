from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from app.core.pagination import CursorPage


class WorkoutBrowseOut(BaseModel):
    title: str
    subtitle: str
    hero_image_url: str
    active_dot_index: int
    dot_count: int


class WorkoutListItemOut(BaseModel):
    id: UUID
    title: str
    total_exercises: int
    reps: int
    thumbnail_url: str


class WorkoutCategoryOut(BaseModel):
    id: UUID
    code: str
    title: str
    description: str
    header_image_url: str
    total_workouts: int
    items: CursorPage[WorkoutListItemOut]


class WorkoutDetailOut(BaseModel):
    id: UUID
    category_id: UUID
    title: str
    coach_label: str
    duration_minutes: int
    calories: int
    sets: int
    reps: int
    total_exercises: int
    hero_image_url: str
    thumbnail_url: str


class WorkoutCompleteRequest(BaseModel):
    duration_minutes: int | None = Field(default=None, ge=1)
    calories_burned: int | None = Field(default=None, ge=0)
    avg_bpm: int | None = Field(default=None, ge=30, le=250)


class WorkoutCompleteOut(BaseModel):
    session_id: UUID
    workout_id: UUID
    title: str
    hero_image_url: str
    calories_burned: int
    duration_minutes: int
    avg_bpm: int
    completed_at: datetime
