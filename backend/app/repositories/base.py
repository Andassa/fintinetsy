from collections.abc import Sequence
from typing import Generic, TypeVar
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.base import Base

ModelT = TypeVar("ModelT", bound=Base)


class GenericRepository(Generic[ModelT]):
    def __init__(self, model: type[ModelT]) -> None:
        self.model = model

    async def get_by_id(self, session: AsyncSession, id: UUID) -> ModelT | None:
        return await session.get(self.model, id)

    async def list_all(self, session: AsyncSession, limit: int = 100) -> Sequence[ModelT]:
        result = await session.execute(select(self.model).limit(limit))
        return result.scalars().all()

    async def add(self, session: AsyncSession, entity: ModelT) -> ModelT:
        session.add(entity)
        await session.flush()
        await session.refresh(entity)
        return entity

    async def delete(self, session: AsyncSession, entity: ModelT) -> None:
        await session.delete(entity)
        await session.flush()
