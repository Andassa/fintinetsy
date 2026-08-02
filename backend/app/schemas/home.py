from datetime import datetime

from pydantic import BaseModel


class AlignmentOut(BaseModel):
    x: float
    y: float


class HomeUserGreetingOut(BaseModel):
    name: str
    date: datetime
    kcal: int
    hunger_status: str
    notification_count: int
    avatar_url: str | None


class HomeCategoryOut(BaseModel):
    id: str
    label: str
    icon_key: str
    is_selected: bool


class HomeWorkoutCardOut(BaseModel):
    id: str
    title: str
    subtitle: str
    duration_minutes: int
    calories: int
    image_url: str


class HomeDietCardOut(BaseModel):
    id: str
    title: str
    calories: int
    duration_minutes: int
    protein_g: int
    fats_g: int
    image_url: str


class HomeActivityBlobOut(BaseModel):
    hours_label: str
    color_hex: str
    rotation_deg: float
    width_factor: float
    height_factor: float
    alignment: AlignmentOut


class HomeAiCoachCardOut(BaseModel):
    conversations_count: int
    subtitle: str
    image_url: str


class HomeDashboardOut(BaseModel):
    user: HomeUserGreetingOut
    categories: list[HomeCategoryOut]
    workout: HomeWorkoutCardOut
    diet: HomeDietCardOut
    activities: list[HomeActivityBlobOut]
    ai_coach: HomeAiCoachCardOut
