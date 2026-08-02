# Uplift.ai (Fintinetsy)

Full-stack fitness app: **Flutter** client + **FastAPI** backend, connected over REST with JWT authentication, Hive offline cache, and ETag revalidation.

## Architecture

```
lib/
  core/           # DI, router, theme, network (Dio + Hive + secure tokens)
  features/       # feature-first Clean Architecture
    */domain/     # entities, repository contracts, use cases
    */data/       # HTTP repositories (real API)
    */presentation/
backend/
  app/            # FastAPI: router → service → repository → model
```

State management: **Provider**. Navigation: **GoRouter**. Networking: **Dio**.

## Prerequisites

- Flutter SDK 3.12+
- Python 3.11+ (backend)
- Backend running on port `8000` (see `backend/README.md`)

## Backend setup

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
alembic upgrade head
uvicorn app.main:app --reload --port 8000
```

API docs: http://127.0.0.1:8000/docs  
Base path used by the app: `/api/v1`

## Flutter setup

```bash
flutter pub get
flutter run
```

### API URL (important)

| Platform | Default / recommended `API_BASE_URL` |
|----------|--------------------------------------|
| macOS / iOS simulator / desktop | `http://127.0.0.1:8000/api/v1` (default) |
| Android emulator | `http://10.0.2.2:8000/api/v1` |

```bash
# Android emulator example
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

All feature repositories talk to the real REST API (no fake/local data repositories).

## Auth (JWT)

1. Register / login → `access_token` + `refresh_token` stored in **flutter_secure_storage**
2. Dio interceptor injects `Authorization: Bearer …`
3. On `401`, interceptor calls `POST /auth/refresh`, rotates tokens, retries the request
4. Logout clears tokens and calls `POST /auth/logout`
5. GoRouter redirects unauthenticated users to Sign In

## Screens fed by the real REST API

- Sign In / Sign Up / Reset password / Logout
- Home dashboard (`GET /home/dashboard`)
- Search (`GET /search`, `/search/suggestions`)
- Assessment config + profile (`/assessment/config`, `/users/me/assessment`)
- Workouts browse / category / detail / complete
- Nutrition meals draft / scan / create
- Stats (hydration, heart rate, calories, uplift score) + activities
- AI coach hub / chats / thread
- Profile (`/users/me` + assessment + stats)
- Settings + notifications

## Offline & caching

- Successful GET responses are stored in **Hive** (`EtagCache`) with ETag values
- `If-None-Match` is sent on subsequent GETs; `304` serves the Hive body
- On connection errors, GET handlers fall back to the last Hive body when available
- User-facing messages come from `ApiException` (timeouts, offline, 401, 429, …)

## Tests

```bash
# Flutter — repository unit tests (Dio + http_mock_adapter)
flutter test

# Backend
cd backend && pytest -q
```

Minimum repository coverage includes auth, home, search/workouts, and refresh/ETag client tests.

## CI

GitHub Actions (`.github/workflows/ci.yml`) runs `flutter analyze`, `flutter test`, and backend `pytest`.

## Lint

`analysis_options.yaml` includes `flutter_lints` plus stricter rules (`prefer_const_constructors`, `avoid_print`, …).
