from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = "Uplift.ai API"
    app_env: str = "development"
    debug: bool = True
    api_v1_prefix: str = "/api/v1"

    secret_key: str = Field(
        default="dev-only-secret-key-change-me",
        min_length=16,
    )
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 30
    password_min_length: int = 8

    database_url: str = "sqlite+aiosqlite:///./uplift.db"
    redis_url: str = "redis://localhost:6379/0"
    cors_origins: list[str] = Field(default_factory=lambda: ["*"])

    rate_limit_enabled: bool = True
    rate_limit_auth_limit: int = 5
    rate_limit_auth_window_seconds: int = 900
    etag_enabled: bool = True

    # OAuth (Google). When mock is enabled, id_tokens prefixed with `mock.` are accepted.
    oauth_google_client_id: str = ""
    oauth_allow_mock: bool = True


@lru_cache
def get_settings() -> Settings:
    return Settings()
