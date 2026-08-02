"""ETag + Cache-Control middleware for stable GET endpoints."""

from __future__ import annotations

import hashlib

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

ETAG_PATHS = {
    "/api/v1/workouts/browse",
    "/api/v1/assessment/config",
    "/api/v1/search/suggestions",
}


class ETagMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        if request.method != "GET" or request.url.path not in ETAG_PATHS:
            return await call_next(request)

        response = await call_next(request)
        if response.status_code != 200:
            return response

        body = b""
        async for chunk in response.body_iterator:
            body += chunk if isinstance(chunk, bytes) else chunk.encode("utf-8")

        etag = hashlib.md5(body).hexdigest()
        if_none_match = request.headers.get("if-none-match")
        if if_none_match and if_none_match.strip('"') == etag:
            return Response(
                status_code=304,
                headers={
                    "ETag": f'"{etag}"',
                    "Cache-Control": "private, max-age=60",
                },
            )

        headers = dict(response.headers)
        headers["ETag"] = f'"{etag}"'
        headers["Cache-Control"] = "private, max-age=60"
        return Response(
            content=body,
            status_code=response.status_code,
            headers=headers,
            media_type=response.media_type,
        )
