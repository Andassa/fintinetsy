from fastapi import APIRouter, Depends, Response, status

from app.core.dependencies import AuthSvc, CurrentUser, DbSession
from app.core.rate_limit import rate_limit_auth
from app.schemas.auth import (
    AuthResponse,
    LoginRequest,
    MessageOut,
    OAuthGoogleRequest,
    PasswordResetRequestBody,
    PasswordResetResendBody,
    PasswordResetResponse,
    RefreshRequest,
    RegisterRequest,
    ResetMethodOut,
)

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post(
    "/register",
    response_model=AuthResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(rate_limit_auth)],
)
async def register(
    body: RegisterRequest,
    session: DbSession,
    auth: AuthSvc,
) -> AuthResponse:
    return await auth.register(
        session,
        email=str(body.email),
        password=body.password,
        confirm_password=body.confirm_password,
    )


@router.post(
    "/login",
    response_model=AuthResponse,
    dependencies=[Depends(rate_limit_auth)],
)
async def login(
    body: LoginRequest,
    session: DbSession,
    auth: AuthSvc,
) -> AuthResponse:
    return await auth.login(session, email=str(body.email), password=body.password)


@router.post(
    "/refresh",
    response_model=AuthResponse,
    dependencies=[Depends(rate_limit_auth)],
)
async def refresh(
    body: RefreshRequest,
    session: DbSession,
    auth: AuthSvc,
) -> AuthResponse:
    return await auth.refresh(session, body.refresh_token)


@router.post(
    "/oauth/google",
    response_model=AuthResponse,
    dependencies=[Depends(rate_limit_auth)],
)
async def oauth_google(
    body: OAuthGoogleRequest,
    session: DbSession,
    auth: AuthSvc,
) -> AuthResponse:
    """Google OAuth2 / OpenID Connect sign-in (ID token → JWT session)."""
    return await auth.oauth_google(
        session,
        id_token=body.id_token,
        email=str(body.email) if body.email else None,
        name=body.name,
    )


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    session: DbSession,
    auth: AuthSvc,
    user: CurrentUser,
) -> Response:
    await auth.logout(session, user.id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/reset-methods", response_model=list[ResetMethodOut])
async def reset_methods(auth: AuthSvc) -> list[ResetMethodOut]:
    return auth.list_reset_methods()


@router.post(
    "/password-reset",
    response_model=PasswordResetResponse,
    dependencies=[Depends(rate_limit_auth)],
)
async def password_reset(
    body: PasswordResetRequestBody,
    session: DbSession,
    auth: AuthSvc,
) -> PasswordResetResponse:
    return await auth.request_password_reset(session, str(body.email), body.method)


@router.post(
    "/password-reset/resend",
    response_model=PasswordResetResponse,
    dependencies=[Depends(rate_limit_auth)],
)
async def password_reset_resend(
    body: PasswordResetResendBody,
    session: DbSession,
    auth: AuthSvc,
) -> PasswordResetResponse:
    return await auth.request_password_reset(session, str(body.email), "email")


@router.get("/me", response_model=MessageOut)
async def me(user: CurrentUser) -> MessageOut:
    return MessageOut(message=f"Authenticated as {user.email}")
