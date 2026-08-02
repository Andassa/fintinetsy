from collections.abc import AsyncGenerator
from typing import Annotated
from uuid import UUID

import jwt
from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.exceptions import UnauthorizedException
from app.core.security import decode_access_token
from app.db.session import get_db
from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.services.auth_service import AuthService

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl=f"{get_settings().api_v1_prefix}/auth/login",
    auto_error=False,
)

DbSession = Annotated[AsyncSession, Depends(get_db)]


def get_auth_service() -> AuthService:
    return AuthService()


AuthSvc = Annotated[AuthService, Depends(get_auth_service)]


async def get_current_user(
    session: DbSession,
    token: Annotated[str | None, Depends(oauth2_scheme)],
) -> User:
    if not token:
        raise UnauthorizedException("Missing access token")
    try:
        payload = decode_access_token(token)
        user_id = UUID(payload["sub"])
    except (jwt.PyJWTError, KeyError, ValueError) as exc:
        raise UnauthorizedException("Invalid or expired access token") from exc
    user = await UserRepository().get_by_id(session, user_id)
    if user is None:
        raise UnauthorizedException("User not found")
    return user


CurrentUser = Annotated[User, Depends(get_current_user)]
