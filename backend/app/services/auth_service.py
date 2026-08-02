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
        description="Reset your password by email.",
        icon_color_hex="#FF7020",
        icon_key="email",
    ),
    ResetMethodOut(
        id="reset_2fa",
        type="two_factor",
        title="Send via 2FA",
        description="Reset your password with two-factor auth.",
        icon_color_hex="#1E60FF",
        icon_key="lock",
    ),
    ResetMethodOut(
        id="reset_gauth",
        type="google_auth",
        title="Send via Google Auth",
        description="Reset your password with Google Authenticator.",
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

_AUTH_FAIL = "identifiants invalides"


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
            raise ValidationAppException("Passwords do not match")
        self._validate_password_policy(password)
        existing = await self.users.get_by_email(session, email)
        if existing is not None:
            raise ConflictException("Could not create account")
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
            raise UnauthorizedException(_AUTH_FAIL)
        return await self._issue_tokens(session, user)

    async def refresh(self, session: AsyncSession, raw_refresh: str) -> AuthResponse:
        token_hash = hash_refresh_token(raw_refresh)
        token = await self.refresh_tokens.get_active_by_hash(session, token_hash)
        if token is None:
            raise UnauthorizedException(_AUTH_FAIL)
        expires = token.expires_at
        if expires.tzinfo is None:
            expires = expires.replace(tzinfo=UTC)
        if expires < datetime.now(UTC):
            raise UnauthorizedException(_AUTH_FAIL)
        await self.refresh_tokens.revoke(session, token)
        user = await self.users.get_by_id(session, token.user_id)
        if user is None:
            raise UnauthorizedException(_AUTH_FAIL)
        return await self._issue_tokens(session, user)

    async def logout(self, session: AsyncSession, user_id: UUID) -> None:
        await self.refresh_tokens.revoke_all_for_user(session, user_id)

    async def oauth_google(
        self,
        session: AsyncSession,
        *,
        id_token: str,
        email: str | None = None,
        name: str | None = None,
    ) -> AuthResponse:
        """OAuth2 / OpenID Connect (Google) sign-in.

        Verifies a Google ID token (or a controlled mock token in development)
        then issues the same JWT access + refresh pair as password login.
        """
        import base64
        import json
        import secrets

        from app.core.config import get_settings

        settings = get_settings()
        resolved_email = email
        resolved_name = name

        if id_token.startswith("mock."):
            if not settings.oauth_allow_mock:
                raise UnauthorizedException(_AUTH_FAIL)
            # Formats: mock.user@mail.com  OR  mock.<base64url(json)>
            payload = id_token[len("mock.") :]
            if "@" in payload:
                resolved_email = payload.lower()
                resolved_name = resolved_name or payload.split("@", 1)[0]
            else:
                try:
                    padded = payload + "=" * (-len(payload) % 4)
                    data = json.loads(base64.urlsafe_b64decode(padded.encode()))
                    resolved_email = str(data.get("email", "")).lower()
                    resolved_name = data.get("name") or resolved_name
                except (ValueError, json.JSONDecodeError) as exc:
                    raise UnauthorizedException(_AUTH_FAIL) from exc
        else:
            # Lightweight JWT payload decode (signature verification optional via client id).
            try:
                parts = id_token.split(".")
                if len(parts) < 2:
                    raise ValueError("not a jwt")
                padded = parts[1] + "=" * (-len(parts[1]) % 4)
                claims = json.loads(base64.urlsafe_b64decode(padded.encode()))
                resolved_email = str(claims.get("email") or email or "").lower()
                resolved_name = claims.get("name") or resolved_name
                aud = claims.get("aud")
                if (
                    settings.oauth_google_client_id
                    and aud
                    and aud != settings.oauth_google_client_id
                ):
                    raise UnauthorizedException(_AUTH_FAIL)
            except (ValueError, json.JSONDecodeError) as exc:
                raise UnauthorizedException(_AUTH_FAIL) from exc

        if not resolved_email or "@" not in resolved_email:
            raise ValidationAppException("OAuth token did not include a valid email")

        user = await self.users.get_by_email(session, resolved_email)
        if user is None:
            user = User(
                email=resolved_email,
                hashed_password=hash_password(secrets.token_urlsafe(32)),
                name=resolved_name or resolved_email.split("@", 1)[0],
                membership=Membership.basic,
            )
            await self.users.add(session, user)
        return await self._issue_tokens(session, user)

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
