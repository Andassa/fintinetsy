from datetime import datetime
from typing import Generic, TypeVar
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field

T = TypeVar("T")


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

    def passwords_match(self) -> bool:
        return self.password == self.confirm_password


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


class CursorPage(BaseModel, Generic[T]):
    items: list[T]
    next_cursor: str | None = None
    has_more: bool = False
