from pydantic import BaseModel, ConfigDict, EmailStr, Field


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class FitnessGoalOut(ORMModel):
    id: str
    label: str
    icon_key: str


class VocalAssessmentOut(BaseModel):
    prompt: str
    highlighted_words: str
    subtitle: str


class AssessmentConfigOut(BaseModel):
    min_age: int
    max_age: int
    default_age: int
    min_weight_kg: float
    max_weight_kg: float
    default_weight_kg: float
    fitness_labels: list[str]
    goals: list[FitnessGoalOut]
    vocal: VocalAssessmentOut


class AssessmentProfileOut(BaseModel):
    age: int | None
    weight_kg: float | None
    weight_unit: str
    fitness_level: int
    gender: str | None
    goal_id: str | None
    avatar_id: str | None
    vocal_completed: bool


class AssessmentProfileUpdate(BaseModel):
    age: int | None = Field(default=None, ge=1, le=120)
    weight_kg: float | None = Field(default=None, gt=0, le=500)
    weight_unit: str | None = Field(default=None, pattern="^(kg|lbs)$")
    fitness_level: int | None = Field(default=None, ge=1, le=6)
    gender: str | None = Field(default=None, pattern="^(male|female|skipped)$")
    goal_id: str | None = None
    avatar_id: str | None = None
    vocal_completed: bool | None = None


class UserMeOut(ORMModel):
    id: str
    email: EmailStr
    name: str
    avatar_url: str | None
    membership: str
