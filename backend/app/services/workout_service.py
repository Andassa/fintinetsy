from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException
from app.models.workout import (
    Workout,
    WorkoutBrowseSeed,
    WorkoutCategory,
    WorkoutSession,
)
from app.repositories.workout_repository import (
    WorkoutBrowseRepository,
    WorkoutCategoryRepository,
    WorkoutRepository,
    WorkoutSessionRepository,
)
from app.schemas.workout import (
    WorkoutBrowseOut,
    WorkoutCategoryOut,
    WorkoutCompleteOut,
    WorkoutCompleteRequest,
    WorkoutDetailOut,
)

from app.core.constants import CDN_BASE_URL


class WorkoutService:
    def __init__(self) -> None:
        self.categories = WorkoutCategoryRepository()
        self.workouts = WorkoutRepository()
        self.browse = WorkoutBrowseRepository()
        self.sessions = WorkoutSessionRepository()

    async def ensure_seed_data(self, session: AsyncSession) -> None:
        if await self.browse.get_active(session) is None:
            await self.browse.add(
                session,
                WorkoutBrowseSeed(
                    title="Personalized Workout & Training",
                    subtitle=(
                        "Workout categories will help you gain strength, "
                        "get in better shape and embrace a healthy lifestyle"
                    ),
                    hero_image_url=f"{CDN_BASE_URL}/workouts/browse-hero.png",
                    active_dot_index=1,
                    dot_count=3,
                    is_active=True,
                ),
            )
        existing = await self.categories.get_by_code(session, "strength")
        if existing is None:
            await self._seed_strength_category(session)

    async def _seed_strength_category(self, session: AsyncSession) -> None:
        category = await self.categories.add(
            session,
            WorkoutCategory(
                code="strength",
                title="Strength",
                description=(
                    "Build bigger and stronger muscles with this exercise. "
                    "Train everyday to get bulk"
                ),
                header_image_url=f"{CDN_BASE_URL}/workouts/strength-header.png",
                sort_order=0,
            ),
        )
        for i in range(4):
            await self.workouts.add(
                session,
                Workout(
                    category_id=category.id,
                    code=f"back_{i + 1}",
                    title="Back Workout",
                    coach_label="With Azunyan U. WU",
                    duration_minutes=58,
                    calories=254,
                    sets=3,
                    reps=30,
                    total_exercises=10,
                    hero_image_url=f"{CDN_BASE_URL}/workouts/back-hero.png",
                    thumbnail_url=f"{CDN_BASE_URL}/workouts/back-thumb.png",
                    sort_order=i,
                ),
            )

    async def get_browse(self, session: AsyncSession) -> WorkoutBrowseOut:
        await self.ensure_seed_data(session)
        row = await self.browse.get_active(session)
        if row is None:
            raise NotFoundException("Browse page missing")
        return WorkoutBrowseOut(
            title=row.title,
            subtitle=row.subtitle,
            hero_image_url=row.hero_image_url,
            active_dot_index=row.active_dot_index,
            dot_count=row.dot_count,
        )

    async def get_category(
        self,
        session: AsyncSession,
        category_id: str,
        cursor: str | None,
        limit: int,
    ) -> WorkoutCategoryOut:
        await self.ensure_seed_data(session)
        category = await self.categories.get_by_id_or_code(session, category_id)
        if category is None:
            raise NotFoundException("Category not found")
        total = await self.workouts.count_by_category(session, category.id)
        items = await self.workouts.list_by_category_cursor(
            session,
            category.id,
            cursor,
            limit,
        )
        return WorkoutCategoryOut(
            id=category.id,
            code=category.code,
            title=category.title,
            description=category.description,
            header_image_url=category.header_image_url,
            total_workouts=total,
            items=items,
        )

    async def get_workout(
        self,
        session: AsyncSession,
        workout_id: UUID,
    ) -> WorkoutDetailOut:
        await self.ensure_seed_data(session)
        workout = await self.workouts.get_detail(session, workout_id)
        if workout is None:
            raise NotFoundException("Workout not found")
        return self._to_detail(workout)

    def _to_detail(self, workout: Workout) -> WorkoutDetailOut:
        return WorkoutDetailOut(
            id=workout.id,
            category_id=workout.category_id,
            title=workout.title,
            coach_label=workout.coach_label,
            duration_minutes=workout.duration_minutes,
            calories=workout.calories,
            sets=workout.sets,
            reps=workout.reps,
            total_exercises=workout.total_exercises,
            hero_image_url=workout.hero_image_url,
            thumbnail_url=workout.thumbnail_url,
        )

    async def complete_workout(
        self,
        session: AsyncSession,
        user_id: UUID,
        workout_id: UUID,
        body: WorkoutCompleteRequest,
    ) -> WorkoutCompleteOut:
        await self.ensure_seed_data(session)
        workout = await self.workouts.get_by_id(session, workout_id)
        if workout is None:
            raise NotFoundException("Workout not found")
        now = datetime.now(UTC)
        duration = body.duration_minutes or workout.duration_minutes
        calories = body.calories_burned or workout.calories
        bpm = body.avg_bpm or 130
        started = now
        session_row = WorkoutSession(
            user_id=user_id,
            workout_id=workout.id,
            started_at=started,
            completed_at=now,
            calories_burned=calories,
            duration_minutes=duration,
            avg_bpm=bpm,
        )
        saved = await self.sessions.add(session, session_row)
        return WorkoutCompleteOut(
            session_id=saved.id,
            workout_id=workout.id,
            title=f"{workout.title} Complete",
            hero_image_url=workout.hero_image_url,
            calories_burned=calories,
            duration_minutes=duration,
            avg_bpm=bpm,
            completed_at=now,
        )
