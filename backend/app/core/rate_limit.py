"""Sliding-window rate limiter (in-memory)."""

from __future__ import annotations

import time
from collections import defaultdict, deque
from threading import Lock

from fastapi import Request

from app.core.config import get_settings
from app.core.exceptions import AppException


class RateLimitException(AppException):
    def __init__(self, message: str = "Too many requests") -> None:
        super().__init__(
            code="rate_limited",
            message=message,
            status_code=429,
        )


class SlidingWindowLimiter:
    def __init__(self) -> None:
        self._hits: dict[str, deque[float]] = defaultdict(deque)
        self._lock = Lock()

    def hit(self, key: str, limit: int, window_seconds: int) -> None:
        now = time.monotonic()
        cutoff = now - window_seconds
        with self._lock:
            bucket = self._hits[key]
            while bucket and bucket[0] < cutoff:
                bucket.popleft()
            if len(bucket) >= limit:
                raise RateLimitException(
                    f"Rate limit exceeded ({limit}/{window_seconds}s)",
                )
            bucket.append(now)


_limiter = SlidingWindowLimiter()


async def rate_limit_auth(request: Request) -> None:
    settings = get_settings()
    if not settings.rate_limit_enabled:
        return
    client = request.client.host if request.client else "unknown"
    path = request.url.path
    key = f"auth:{client}:{path}"
    _limiter.hit(
        key,
        limit=settings.rate_limit_auth_limit,
        window_seconds=settings.rate_limit_auth_window_seconds,
    )
