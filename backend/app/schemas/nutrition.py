from datetime import datetime
from enum import Enum
from uuid import UUID

from pydantic import BaseModel, Field


class MealTypeOut(str, Enum):
    breakfast = "breakfast"
    lunch = "lunch"
    dinner = "dinner"
    snack = "snack"


class MealEntryMethodOut(str, Enum):
    manual = "manual"
    ai_scan = "ai_scan"


class MealDraftOut(BaseModel):
    name: str
    type: MealTypeOut
    protein_g: float
    carbs_g: float
    fat_g: float
    entry_method: MealEntryMethodOut
    image_url: str | None = None


class MealCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    type: MealTypeOut
    protein_g: float = Field(ge=0, le=500)
    carbs_g: float = Field(ge=0, le=500)
    fat_g: float = Field(ge=0, le=500)
    entry_method: MealEntryMethodOut = MealEntryMethodOut.manual
    image_url: str | None = Field(default=None, max_length=512)
    logged_at: datetime | None = None


class MealOut(BaseModel):
    id: UUID
    name: str
    type: MealTypeOut
    protein_g: float
    carbs_g: float
    fat_g: float
    entry_method: MealEntryMethodOut
    image_url: str | None
    logged_at: datetime


class MealScanRequest(BaseModel):
    image_url: str | None = Field(default=None, max_length=512)


class MealScanOut(BaseModel):
    image_url: str
    status_label: str
    progress: float
