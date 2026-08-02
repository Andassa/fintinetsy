from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException, ValidationAppException
from app.models.assessment import (
    AssessmentConfigRow,
    AssessmentProfile,
    FitnessGoal,
    GenderOption,
    WeightUnit,
)
from app.repositories.assessment_repository import (
    AssessmentConfigRepository,
    AssessmentProfileRepository,
    FitnessGoalRepository,
)
from app.schemas.assessment import (
    AssessmentConfigOut,
    AssessmentProfileOut,
    AssessmentProfileUpdate,
    FitnessGoalOut,
    VocalAssessmentOut,
)

DEFAULT_GOALS = [
    ("lose_weight", "I wanna lose weight", "scale"),
    ("ai_coach", "I wanna try AI Coach", "smart_toy"),
    ("bulk", "I wanna get bulks", "fitness_center"),
    ("endurance", "I wanna gain endurance", "favorite"),
    ("trying", "Just trying out the app! 👍", "phone_iphone"),
]

DEFAULT_VOCAL = {
    "prompt": "If there's no pain, then there's always no gain.",
    "highlighted": "If there's",
    "subtitle": (
        "Your voice is connected to your health. "
        "Say the following for better assessment. 🙌"
    ),
}

DEFAULT_LABELS = (
    "Beginner,Novice,Somewhat Athletic,Athletic,Very Athletic,Elite"
)


class AssessmentService:
    def __init__(self) -> None:
        self.goals = FitnessGoalRepository()
        self.config = AssessmentConfigRepository()
        self.profiles = AssessmentProfileRepository()

    async def ensure_seed_data(self, session: AsyncSession) -> None:
        existing = await self.goals.list_all_ordered(session)
        if not existing:
            for code, label, icon in DEFAULT_GOALS:
                await self.goals.add(
                    session,
                    FitnessGoal(code=code, label=label, icon_key=icon),
                )
        if await self.config.get_singleton(session) is None:
            await self.config.add(
                session,
                AssessmentConfigRow(
                    min_age=12,
                    max_age=80,
                    default_age=19,
                    min_weight_kg=30.0,
                    max_weight_kg=180.0,
                    default_weight_kg=62.0,
                    fitness_labels_csv=DEFAULT_LABELS,
                    vocal_prompt=DEFAULT_VOCAL["prompt"],
                    vocal_highlighted_words=DEFAULT_VOCAL["highlighted"],
                    vocal_subtitle=DEFAULT_VOCAL["subtitle"],
                ),
            )

    async def get_config(self, session: AsyncSession) -> AssessmentConfigOut:
        await self.ensure_seed_data(session)
        row = await self.config.get_singleton(session)
        if row is None:
            raise NotFoundException("Assessment config missing")
        goals = await self.goals.list_all_ordered(session)
        return AssessmentConfigOut(
            min_age=row.min_age,
            max_age=row.max_age,
            default_age=row.default_age,
            min_weight_kg=row.min_weight_kg,
            max_weight_kg=row.max_weight_kg,
            default_weight_kg=row.default_weight_kg,
            fitness_labels=[x.strip() for x in row.fitness_labels_csv.split(",")],
            goals=[
                FitnessGoalOut(id=g.code, label=g.label, icon_key=g.icon_key)
                for g in goals
            ],
            vocal=VocalAssessmentOut(
                prompt=row.vocal_prompt,
                highlighted_words=row.vocal_highlighted_words,
                subtitle=row.vocal_subtitle,
            ),
        )

    def _to_out(self, profile: AssessmentProfile) -> AssessmentProfileOut:
        return AssessmentProfileOut(
            age=profile.age,
            weight_kg=profile.weight_kg,
            weight_unit=profile.weight_unit.value,
            fitness_level=profile.fitness_level,
            gender=profile.gender.value if profile.gender else None,
            goal_id=profile.goal_code,
            avatar_id=profile.avatar_id,
            vocal_completed=profile.vocal_completed,
        )

    async def get_or_create_profile(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> AssessmentProfileOut:
        await self.ensure_seed_data(session)
        profile = await self.profiles.get_for_user(session, user_id)
        if profile is None:
            cfg = await self.config.get_singleton(session)
            profile = AssessmentProfile(
                user_id=user_id,
                age=cfg.default_age if cfg else 19,
                weight_kg=cfg.default_weight_kg if cfg else 62.0,
                weight_unit=WeightUnit.kg,
                fitness_level=3,
                vocal_completed=False,
            )
            await self.profiles.add(session, profile)
        return self._to_out(profile)

    async def update_profile(
        self,
        session: AsyncSession,
        user_id: UUID,
        data: AssessmentProfileUpdate,
    ) -> AssessmentProfileOut:
        await self.ensure_seed_data(session)
        profile = await self.profiles.get_for_user(session, user_id)
        if profile is None:
            profile = AssessmentProfile(user_id=user_id)
            await self.profiles.add(session, profile)
        await self._apply_update(session, profile, data)
        await session.flush()
        await session.refresh(profile)
        return self._to_out(profile)

    async def _apply_update(
        self,
        session: AsyncSession,
        profile: AssessmentProfile,
        data: AssessmentProfileUpdate,
    ) -> None:
        cfg = await self.config.get_singleton(session)
        payload = data.model_dump(exclude_unset=True)
        if "age" in payload and payload["age"] is not None and cfg:
            if not (cfg.min_age <= payload["age"] <= cfg.max_age):
                raise ValidationAppException("Age out of allowed range")
            profile.age = payload["age"]
        if "weight_kg" in payload and payload["weight_kg"] is not None and cfg:
            if not (cfg.min_weight_kg <= payload["weight_kg"] <= cfg.max_weight_kg):
                raise ValidationAppException("Weight out of allowed range")
            profile.weight_kg = payload["weight_kg"]
        if "weight_unit" in payload and payload["weight_unit"] is not None:
            profile.weight_unit = WeightUnit(payload["weight_unit"])
        if "fitness_level" in payload and payload["fitness_level"] is not None:
            profile.fitness_level = payload["fitness_level"]
        if "gender" in payload:
            profile.gender = (
                GenderOption(payload["gender"]) if payload["gender"] else None
            )
        if "goal_id" in payload:
            await self._set_goal(session, profile, payload["goal_id"])
        if "avatar_id" in payload:
            profile.avatar_id = payload["avatar_id"]
        if "vocal_completed" in payload and payload["vocal_completed"] is not None:
            profile.vocal_completed = payload["vocal_completed"]

    async def _set_goal(
        self,
        session: AsyncSession,
        profile: AssessmentProfile,
        goal_id: str | None,
    ) -> None:
        if goal_id is None:
            profile.goal_code = None
            return
        goal = await self.goals.get_by_code(session, goal_id)
        if goal is None:
            raise ValidationAppException("Unknown goal_id")
        profile.goal_code = goal.code
