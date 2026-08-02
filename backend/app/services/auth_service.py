from datetime import UTC, datetime, timedelta
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.exceptions import (
    ConflictException,
    UnauthorizedException,
    ValidationAppException,
)
from app.core.security import (
    create_access_token,
    generate_refresh_token,
    hash_password,
    hash_refresh_token,
    verify_password,
)
from app.models.user import Membership, RefreshToken, User
from app.repositories.user_repository import (
    PasswordResetRepository,
    RefreshTokenRepository,
    UserRepository,
)
from app.schemas.auth import AuthResponse, PasswordResetResponse, ResetMethodOut, UserPublic

RESET_METHODS: list[ResetMethodOut] = [
    ResetMethodOut(
        id="reset_email",
        type="email",
        title="Send via Email",
        description="Seamlessly reset your password via email address.",
        icon_color_hex="#FF7020",
        icon_key="email",
    ),
    ResetMethodOut(
        id="reset_2fa",
        type="two_factor",
        title="Send via 2FA",
        description="Seamlessly reset your password via 2 Factors.",
        icon_color_hex="#1E60FF",
        icon_key="lock",
    ),
    ResetMethodOut(
        id="reset_gauth",
        type="google_auth",
        title="Send via Google Auth",
        description="Seamlessly reset your password via gAuth.",
        icon_color_hex="#8A2BE2",
        icon_key="gauth",
    ),
]

_METHOD_ALIASES = {
    "reset_email": "email",
    "reset_2fa": "two_factor",
    "reset_gauth": "google_auth",
    "twoFactor": "two_factor",
    "googleAuth": "google_auth",
}


class AuthService:
    def __init__(self) -> None:
        self.users = UserRepository()
        self.refresh_tokens = RefreshTokenRepository()
        self.reset_requests = PasswordResetRepository()

    def _to_public(self, user: User) -> UserPublic:
        return UserPublic(
            id=user.id,
            email=user.email,
            name=user.name,
            avatar_url=user.avatar_url,
            membership=user.membership.value,
        )

    def _validate_password_policy(self, password: str) -> None:
        settings = get_settings()
        if len(password) < settings.password_min_length:
            raise ValidationAppException(
                f"Password must be at least {settings.password_min_length} characters",
            )
        if not any(c.isdigit() for c in password):
            raise ValidationAppException("Password must contain at least one digit")

    async def _issue_tokens(self, session: AsyncSession, user: User) -> AuthResponse:
        access = create_access_token(user.id)
        raw_refresh = generate_refresh_token()
        settings = get_settings()
        expires = datetime.now(UTC) + timedelta(days=settings.refresh_token_expire_days)
        entity = RefreshToken(
            user_id=user.id,
            token_hash=hash_refresh_token(raw_refresh),
            expires_at=expires,
            revoked=False,
        )
        await self.refresh_tokens.add(session, entity)
        return AuthResponse(
            user=self._to_public(user),
            access_token=access,
            refresh_token=raw_refresh,
        )

    async def register(
        self,
        session: AsyncSession,
        email: str,
        password: str,
        confirm_password: str,
    ) -> AuthResponse:
        if password != confirm_password:
            raise ValidationAppException("ERROR: Password Don't Match!")
        self._validate_password_policy(password)
        existing = await self.users.get_by_email(session, email)
        if existing is not None:
            raise ConflictException("Email already registered")
        name = email.split("@", maxsplit=1)[0]
        user = User(
            email=email.lower(),
            hashed_password=hash_password(password),
            name=name,
            membership=Membership.basic,
        )
        await self.users.add(session, user)
        return await self._issue_tokens(session, user)

    async def login(
        self,
        session: AsyncSession,
        email: str,
        password: str,
    ) -> AuthResponse:
        user = await self.users.get_by_email(session, email)
        if user is None or not verify_password(password, user.hashed_password):
            raise UnauthorizedException("Invalid email or password")
        return await self._issue_tokens(session, user)

    async def refresh(self, session: AsyncSession, raw_refresh: str) -> AuthResponse:
        token_hash = hash_refresh_token(raw_refresh)
        token = await self.refresh_tokens.get_active_by_hash(session, token_hash)
        if token is None:
            raise UnauthorizedException("Invalid refresh token")
        expires = token.expires_at
        if expires.tzinfo is None:
            expires = expires.replace(tzinfo=UTC)
        if expires < datetime.now(UTC):
            raise UnauthorizedException("Refresh token expired")
        await self.refresh_tokens.revoke(session, token)
        user = await self.users.get_by_id(session, token.user_id)
        if user is None:
            raise UnauthorizedException("User not found")
        return await self._issue_tokens(session, user)

    async def logout(self, session: AsyncSession, user_id: UUID) -> None:
        await self.refresh_tokens.revoke_all_for_user(session, user_id)

    def list_reset_methods(self) -> list[ResetMethodOut]:
        return list(RESET_METHODS)

    def _normalize_method(self, method: str) -> str:
        return _METHOD_ALIASES.get(method, method)

    async def request_password_reset(
        self,
        session: AsyncSession,
        email: str,
        method: str,
    ) -> PasswordResetResponse:
        method_key = self._normalize_method(method)
        user = await self.users.get_by_email(session, email)
        sent_at = datetime.now(UTC)
        if user is not None:
            await self.reset_requests.create_request(
                session,
                user.id,
                method_key,
                sent_at,
            )
        return PasswordResetResponse(email=email, sent_at=sent_at, can_resend=True)
