from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field, model_validator


class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)


class UserPublic(ORMModel):
    id: UUID
    email: EmailStr
    name: str
    avatar_url: str | None
    membership: str


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)
    confirm_password: str

    @model_validator(mode="after")
    def passwords_must_match(self) -> "RegisterRequest":
        if self.password != self.confirm_password:
            raise ValueError("Passwords do not match")
        return self


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class AuthResponse(BaseModel):
    user: UserPublic
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RefreshRequest(BaseModel):
    refresh_token: str


class PasswordResetRequestBody(BaseModel):
    email: EmailStr
    method: str = "email"


class PasswordResetResendBody(BaseModel):
    email: EmailStr


class PasswordResetResponse(BaseModel):
    email: EmailStr
    sent_at: datetime
    can_resend: bool = True


class ResetMethodOut(BaseModel):
    id: str
    type: str
    title: str
    description: str
    icon_color_hex: str
    icon_key: str


class MessageOut(BaseModel):
    message: str


class OAuthGoogleRequest(BaseModel):
    """Google Sign-In / OAuth2 ID token exchange.

    Production: pass a real Google ID token (`id_token`).
    Development / CI: pass `mock.<email>` when `oauth_allow_mock` is true.
    """

    id_token: str = Field(min_length=3, max_length=4096)
    email: EmailStr | None = None
    name: str | None = Field(default=None, max_length=120)
    access_token: str | None = Field(default=None, max_length=4096)
