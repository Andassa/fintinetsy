from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.core.pagination import decode_cursor, encode_cursor
from app.models.workout import (
    Workout,
    WorkoutBrowseSeed,
    WorkoutCategory,
    WorkoutSession,
)
from app.repositories.base import GenericRepository
from app.schemas.workout import WorkoutListItemOut
from app.core.pagination import CursorPage


class WorkoutCategoryRepository(GenericRepository[WorkoutCategory]):
    def __init__(self) -> None:
        super().__init__(WorkoutCategory)

    async def get_by_code(
        self,
        session: AsyncSession,
        code: str,
    ) -> WorkoutCategory | None:
        result = await session.execute(
            select(WorkoutCategory).where(WorkoutCategory.code == code),
        )
        return result.scalar_one_or_none()

    async def get_by_id_or_code(
        self,
        session: AsyncSession,
        category_id: str,
    ) -> WorkoutCategory | None:
        try:
            uid = UUID(category_id)
            return await self.get_by_id(session, uid)
        except ValueError:
            return await self.get_by_code(session, category_id)


class WorkoutRepository(GenericRepository[Workout]):
    def __init__(self) -> None:
        super().__init__(Workout)

    async def get_by_code(self, session: AsyncSession, code: str) -> Workout | None:
        result = await session.execute(select(Workout).where(Workout.code == code))
        return result.scalar_one_or_none()

    async def get_detail(self, session: AsyncSession, workout_id: UUID) -> Workout | None:
        result = await session.execute(
            select(Workout)
            .where(Workout.id == workout_id)
            .options(selectinload(Workout.category)),
        )
        return result.scalar_one_or_none()

    async def count_by_category(
        self,
        session: AsyncSession,
        category_id: UUID,
    ) -> int:
        result = await session.execute(
            select(func.count()).select_from(Workout).where(
                Workout.category_id == category_id,
            ),
        )
        return int(result.scalar_one())

    async def list_by_category_cursor(
        self,
        session: AsyncSession,
        category_id: UUID,
        cursor: str | None,
        limit: int,
    ) -> CursorPage[WorkoutListItemOut]:
        stmt = (
            select(Workout)
            .where(Workout.category_id == category_id)
            .order_by(Workout.sort_order.asc(), Workout.id.asc())
        )
        payload = decode_cursor(cursor)
        if payload and "sort_order" in payload and "id" in payload:
            stmt = stmt.where(
                (Workout.sort_order > payload["sort_order"])
                | (
                    (Workout.sort_order == payload["sort_order"])
                    & (Workout.id > UUID(payload["id"]))
                ),
            )
        stmt = stmt.limit(limit + 1)
        rows = list((await session.execute(stmt)).scalars().all())
        has_more = len(rows) > limit
        page = rows[:limit]
        next_cursor = None
        if has_more and page:
            last = page[-1]
            next_cursor = encode_cursor(
                {"sort_order": last.sort_order, "id": str(last.id)},
            )
        items = [
            WorkoutListItemOut(
                id=w.id,
                title=w.title,
                total_exercises=w.total_exercises,
                reps=w.reps,
                thumbnail_url=w.thumbnail_url,
            )
            for w in page
        ]
        return CursorPage(items=items, next_cursor=next_cursor, has_more=has_more)


class WorkoutBrowseRepository(GenericRepository[WorkoutBrowseSeed]):
    def __init__(self) -> None:
        super().__init__(WorkoutBrowseSeed)

    async def get_active(self, session: AsyncSession) -> WorkoutBrowseSeed | None:
        result = await session.execute(
            select(WorkoutBrowseSeed)
            .where(WorkoutBrowseSeed.is_active.is_(True))
            .limit(1),
        )
        return result.scalar_one_or_none()


class WorkoutSessionRepository(GenericRepository[WorkoutSession]):
    def __init__(self) -> None:
        super().__init__(WorkoutSession)
