from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


class HydrationOut(BaseModel):
    current_ml: int
    goal_ml: int
    needed_ml: int


class HydrationLogRequest(BaseModel):
    amount_ml: int = Field(ge=1, le=5000)


class HeartRateOut(BaseModel):
    bpm: int
    activity_label: str
    pressure: int
    pressure_unit: str
    oxygen: int
    oxygen_unit: str
    hero_image_url: str


class MacroBarOut(BaseModel):
    label: str
    percent: int
    grams: int
    color_hex: str


class CalorieStatsOut(BaseModel):
    total_kcal: int
    month_label: str
    macros: list[MacroBarOut]


class CalorieIntakePointOut(BaseModel):
    kcal: int
    index: int


class CalorieIntakeOut(BaseModel):
    total_kcal: int
    remaining_kcal: int
    date_label: str
    points: list[CalorieIntakePointOut]
    active_point_index: int
    carbs_g: int
    protein_g: int
    fats_g: int


class ScoreSegmentOut(BaseModel):
    label: str
    percent: int
    color_hex: str


class UpliftScoreOut(BaseModel):
    score: int
    message: str
    segments: list[ScoreSegmentOut]


class HydrationLogOut(BaseModel):
    id: UUID
    value: float
    unit: str
    recorded_at: datetime
    stats: HydrationOut
