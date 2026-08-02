from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.models.stats import HydrationLog, UserStatsGoals
from app.repositories.stats_repository import (
    CalorieLogRepository,
    HeartRateLogRepository,
    HydrationLogRepository,
    UserStatsGoalsRepository,
)
from app.schemas.stats import (
    CalorieIntakeOut,
    CalorieIntakePointOut,
    CalorieStatsOut,
    HeartRateOut,
    HydrationLogOut,
    HydrationLogRequest,
    HydrationOut,
    MacroBarOut,
    ScoreSegmentOut,
    UpliftScoreOut,
)

from app.core.constants import CDN_BASE_URL
DEFAULT_HYDRATION_GOAL = 2000
DEFAULT_CALORIE_GOAL = 1903


class StatsService:
    def __init__(self) -> None:
        self.goals = UserStatsGoalsRepository()
        self.hydration = HydrationLogRepository()
        self.heart = HeartRateLogRepository()
        self.calories = CalorieLogRepository()

    async def _ensure_goals(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> UserStatsGoals:
        row = await self.goals.get_or_none(session, user_id)
        if row is not None:
            return row
        return await self.goals.add(
            session,
            UserStatsGoals(
                user_id=user_id,
                hydration_goal_ml=DEFAULT_HYDRATION_GOAL,
                calorie_goal_kcal=DEFAULT_CALORIE_GOAL,
            ),
        )

    def _day_bounds(self, now: datetime) -> tuple[datetime, datetime]:
        start = datetime(now.year, now.month, now.day, tzinfo=UTC)
        return start, start + timedelta(days=1)

    async def get_hydration(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> HydrationOut:
        goals = await self._ensure_goals(session, user_id)
        start, end = self._day_bounds(datetime.now(UTC))
        current = int(await self.hydration.sum_between(session, user_id, start, end))
        goal = goals.hydration_goal_ml
        return HydrationOut(
            current_ml=current,
            goal_ml=goal,
            needed_ml=max(0, goal - current),
        )

    async def log_hydration(
        self,
        session: AsyncSession,
        user_id: UUID,
        body: HydrationLogRequest,
    ) -> HydrationLogOut:
        now = datetime.now(UTC)
        saved = await self.hydration.add(
            session,
            HydrationLog(
                user_id=user_id,
                value=float(body.amount_ml),
                unit="ml",
                recorded_at=now,
            ),
        )
        stats = await self.get_hydration(session, user_id)
        return HydrationLogOut(
            id=saved.id,
            value=saved.value,
            unit=saved.unit,
            recorded_at=saved.recorded_at,
            stats=stats,
        )

    async def get_heart_rate(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> HeartRateOut:
        latest = await self.heart.latest(session, user_id)
        if latest is None:
            return self._default_heart_rate()
        return HeartRateOut(
            bpm=int(latest.value),
            activity_label=latest.activity_label or "Currently doing: Basketball",
            pressure=latest.pressure or 112,
            pressure_unit="mmHg",
            oxygen=latest.oxygen or 112,
            oxygen_unit="SpO2",
            hero_image_url=f"{CDN_BASE_URL}/stats/basketball-player.png",
        )

    def _default_heart_rate(self) -> HeartRateOut:
        return HeartRateOut(
            bpm=112,
            activity_label="Currently doing: Basketball",
            pressure=112,
            pressure_unit="mmHg",
            oxygen=112,
            oxygen_unit="SpO2",
            hero_image_url=f"{CDN_BASE_URL}/stats/basketball-player.png",
        )

    async def get_calorie_stats(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> CalorieStatsOut:
        now = datetime.now(UTC)
        start = datetime(now.year, now.month, 1, tzinfo=UTC)
        if now.month == 12:
            end = datetime(now.year + 1, 1, 1, tzinfo=UTC)
        else:
            end = datetime(now.year, now.month + 1, 1, tzinfo=UTC)
        total = int(await self.calories.sum_between(session, user_id, start, end))
        return CalorieStatsOut(
            total_kcal=total if total > 0 else 318,
            month_label=now.strftime("%b"),
            macros=self._default_macros(),
        )

    def _default_macros(self) -> list[MacroBarOut]:
        return [
            MacroBarOut(label="Fat", percent=20, grams=201, color_hex="#000000"),
            MacroBarOut(label="Protein", percent=30, grams=201, color_hex="#2F69FF"),
            MacroBarOut(label="Carbs", percent=10, grams=201, color_hex="#FF7A00"),
            MacroBarOut(label="Macro", percent=25, grams=201, color_hex="#8CC622"),
        ]

    async def get_calorie_intake(
        self,
        session: AsyncSession,
        user_id: UUID,
    ) -> CalorieIntakeOut:
        goals = await self._ensure_goals(session, user_id)
        logs = await self.calories.list_recent(session, user_id, limit=6)
        if not logs:
            return self._default_calorie_intake(goals.calorie_goal_kcal)
        points = [
            CalorieIntakePointOut(kcal=int(row.value), index=i)
            for i, row in enumerate(reversed(logs))
        ]
        total = points[-1].kcal if points else 0
        remaining = max(0, goals.calorie_goal_kcal - total)
        now = datetime.now(UTC)
        return CalorieIntakeOut(
            total_kcal=total,
            remaining_kcal=remaining,
            date_label=now.strftime("%B %Y"),
            points=points,
            active_point_index=min(2, len(points) - 1),
            carbs_g=125,
            protein_g=15,
            fats_g=5,
        )

    def _default_calorie_intake(self, goal: int) -> CalorieIntakeOut:
        points = [
            CalorieIntakePointOut(kcal=1650, index=0),
            CalorieIntakePointOut(kcal=1720, index=1),
            CalorieIntakePointOut(kcal=1578, index=2),
            CalorieIntakePointOut(kcal=1810, index=3),
            CalorieIntakePointOut(kcal=1760, index=4),
            CalorieIntakePointOut(kcal=1900, index=5),
        ]
        total = 1745
        return CalorieIntakeOut(
            total_kcal=total,
            remaining_kcal=max(0, goal - total),
            date_label="January 2024",
            points=points,
            active_point_index=2,
            carbs_g=125,
            protein_g=15,
            fats_g=5,
        )

    def get_uplift_score(self) -> UpliftScoreOut:
        return UpliftScoreOut(
            score=88,
            message="You are a healthy individual",
            segments=[
                ScoreSegmentOut(label="Strength", percent=26, color_hex="#FF7A21"),
                ScoreSegmentOut(label="Endurance", percent=24, color_hex="#A283F1"),
                ScoreSegmentOut(label="Agility", percent=54, color_hex="#333333"),
            ],
        )
