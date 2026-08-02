from datetime import UTC, datetime

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.exceptions import NotFoundException
from app.models.home import (
    HomeActivityBlobLayout,
    HomeAiCoachCardSeed,
    HomeCategory,
    HomeFeaturedMeal,
    HomeFeaturedWorkout,
)
from app.models.user import User
from app.repositories.home_repository import (
    HomeActivityBlobRepository,
    HomeAiCoachSeedRepository,
    HomeCategoryRepository,
    HomeFeaturedMealRepository,
    HomeFeaturedWorkoutRepository,
)
from app.schemas.home import (
    AlignmentOut,
    HomeActivityBlobOut,
    HomeAiCoachCardOut,
    HomeCategoryOut,
    HomeDashboardOut,
    HomeDietCardOut,
    HomeUserGreetingOut,
    HomeWorkoutCardOut,
)

CDN = "https://cdn.uplift.ai"


class HomeService:
    def __init__(self) -> None:
        self.categories = HomeCategoryRepository()
        self.workouts = HomeFeaturedWorkoutRepository()
        self.meals = HomeFeaturedMealRepository()
        self.blobs = HomeActivityBlobRepository()
        self.ai_coach = HomeAiCoachSeedRepository()

    async def ensure_seed_data(self, session: AsyncSession) -> None:
        if not await self.categories.list_ordered(session):
            await self._seed_categories(session)
        if await self.workouts.get_active(session) is None:
            await self._seed_workout(session)
        if await self.meals.get_active(session) is None:
            await self._seed_meal(session)
        if not await self.blobs.list_ordered(session):
            await self._seed_blobs(session)
        if await self.ai_coach.get_active(session) is None:
            await self._seed_ai_coach(session)

    async def _seed_categories(self, session: AsyncSession) -> None:
        rows = [
            ("hydration", "Hydration", "flame", 0, True),
            ("score", "Score", "favorite", 1, False),
            ("calorie", "Calorie", "local_fire", 2, False),
        ]
        for code, label, icon, order, selected in rows:
            await self.categories.add(
                session,
                HomeCategory(
                    code=code,
                    label=label,
                    icon_key=icon,
                    sort_order=order,
                    is_default_selected=selected,
                ),
            )

    async def _seed_workout(self, session: AsyncSession) -> None:
        await self.workouts.add(
            session,
            HomeFeaturedWorkout(
                code="wk_upper",
                title="Upper Strength 2",
                subtitle="8 Series Workout",
                duration_minutes=25,
                calories=412,
                image_url=f"{CDN}/workouts/upper-strength-2.png",
                is_active=True,
            ),
        )

    async def _seed_meal(self, session: AsyncSession) -> None:
        await self.meals.add(
            session,
            HomeFeaturedMeal(
                code="diet_salad",
                title="Salad & Egg",
                calories=548,
                duration_minutes=20,
                protein_g=25,
                fats_g=16,
                image_url=f"{CDN}/meals/salad-egg.jpg",
                is_active=True,
            ),
        )

    async def _seed_blobs(self, session: AsyncSession) -> None:
        rows = [
            ("1h", "#FF7A21", -28.0, 0.22, 0.38, -0.85, -0.55, 0),
            ("15h", "#2962FF", 18.0, 0.26, 0.42, 0.75, -0.35, 1),
            ("68h", "#000000", -12.0, 0.42, 0.55, -0.05, 0.05, 2),
            ("7h", "#FF4B4B", 32.0, 0.2, 0.36, -0.7, 0.65, 3),
            ("87h", "#EBEBEB", 8.0, 0.24, 0.5, 0.7, 0.55, 4),
        ]
        for hours, color, rot, wf, hf, ax, ay, order in rows:
            await self.blobs.add(
                session,
                HomeActivityBlobLayout(
                    hours_label=hours,
                    color_hex=color,
                    rotation_deg=rot,
                    width_factor=wf,
                    height_factor=hf,
                    align_x=ax,
                    align_y=ay,
                    sort_order=order,
                ),
            )

    async def _seed_ai_coach(self, session: AsyncSession) -> None:
        await self.ai_coach.add(
            session,
            HomeAiCoachCardSeed(
                conversations_count=1879,
                subtitle="AI Conversation",
                image_url=f"{CDN}/coach/hero.png",
                is_active=True,
            ),
        )

    async def get_dashboard(self, session: AsyncSession, user: User) -> HomeDashboardOut:
        await self.ensure_seed_data(session)
        workout = await self.workouts.get_active(session)
        meal = await self.meals.get_active(session)
        coach = await self.ai_coach.get_active(session)
        if workout is None or meal is None or coach is None:
            raise NotFoundException("Home catalog incomplete")
        categories = await self.categories.list_ordered(session)
        blobs = await self.blobs.list_ordered(session)
        return HomeDashboardOut(
            user=HomeUserGreetingOut(
                name=user.name,
                date=datetime.now(UTC),
                kcal=251,
                hunger_status="Hungry",
                notification_count=0,
                avatar_url=user.avatar_url,
            ),
            categories=[
                HomeCategoryOut(
                    id=c.code,
                    label=c.label,
                    icon_key=c.icon_key,
                    is_selected=c.is_default_selected,
                )
                for c in categories
            ],
            workout=HomeWorkoutCardOut(
                id=workout.code,
                title=workout.title,
                subtitle=workout.subtitle,
                duration_minutes=workout.duration_minutes,
                calories=workout.calories,
                image_url=workout.image_url,
            ),
            diet=HomeDietCardOut(
                id=meal.code,
                title=meal.title,
                calories=meal.calories,
                duration_minutes=meal.duration_minutes,
                protein_g=meal.protein_g,
                fats_g=meal.fats_g,
                image_url=meal.image_url,
            ),
            activities=[
                HomeActivityBlobOut(
                    hours_label=b.hours_label,
                    color_hex=b.color_hex,
                    rotation_deg=b.rotation_deg,
                    width_factor=b.width_factor,
                    height_factor=b.height_factor,
                    alignment=AlignmentOut(x=b.align_x, y=b.align_y),
                )
                for b in blobs
            ],
            ai_coach=HomeAiCoachCardOut(
                conversations_count=coach.conversations_count,
                subtitle=coach.subtitle,
                image_url=coach.image_url,
            ),
        )
