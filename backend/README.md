# Uplift.ai API

FastAPI backend for the Uplift.ai Flutter app.

## Quick start (local SQLite)

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload --port 8000
```

- Health: `GET http://localhost:8000/health`
- Docs: `http://localhost:8000/docs`

## Auth (`/api/v1/auth`)

| Method | Path | Auth |
| ------ | ---- | ---- |
| POST | `/register` | public |
| POST | `/login` | public |
| POST | `/refresh` | public |
| POST | `/logout` | Bearer |
| GET | `/reset-methods` | public |
| POST | `/password-reset` | public |
| POST | `/password-reset/resend` | public |
| GET | `/me` | Bearer |

## Assessment / Users

| Method | Path | Auth |
| ------ | ---- | ---- |
| GET | `/assessment/config` | public |
| GET | `/users/me` | Bearer |
| GET | `/users/me/assessment` | Bearer |
| PUT | `/users/me/assessment` | Bearer |

## Home

| Method | Path | Auth |
| ------ | ---- | ---- |
| GET | `/home/dashboard` | Bearer |

## Workouts

| Method | Path | Auth |
| ------ | ---- | ---- |
| GET | `/workouts/browse` | public |
| GET | `/workouts/categories/{id}` | public |
| GET | `/workouts/{workout_id}` | public |
| POST | `/workouts/{workout_id}/complete` | Bearer |

## Nutrition

| Method | Path | Auth |
| ------ | ---- | ---- |
| GET | `/meals/draft` | Bearer |
| POST | `/meals` | Bearer |
| GET | `/meals/{meal_id}` | Bearer |
| POST | `/meals/scan` | Bearer |

## Stats

| Method | Path | Auth |
| ------ | ---- | ---- |
| GET | `/stats/hydration` | Bearer |
| POST | `/stats/hydration` | Bearer |
| GET | `/stats/heart-rate` | Bearer |
| GET | `/stats/calories` | Bearer |
| GET | `/stats/calories/intake` | Bearer |
| GET | `/stats/uplift-score` | Bearer |

## Activities

| Method | Path | Auth |
| ------ | ---- | ---- |
| GET | `/activities/status` | Bearer |
| GET | `/activities/directions` | Bearer |
| POST | `/activities` | Bearer |
| POST | `/activities/{id}/complete` | Bearer |

## Coach

| Method | Path | Auth |
| ------ | ---- | ---- |
| GET | `/coach/hub` | Bearer |
| GET | `/coach/chats` | Bearer |
| GET | `/coach/chats/{id}/messages` | Bearer |
| POST | `/coach/chats/{id}/messages` | Bearer |

## Settings / Notifications

| Method | Path | Auth |
| ------ | ---- | ---- |
| GET | `/settings` | Bearer |
| PATCH | `/settings` | Bearer |
| GET | `/notifications` | Bearer |
| PATCH | `/notifications/{id}/read` | Bearer |

## Search

| Method | Path | Auth |
| ------ | ---- | ---- |
| GET | `/search` | public |
| GET | `/search/suggestions` | public |

## Notes

- Rate limit on login, register, refresh, password-reset: 5 req / 15 min / IP (`429`)
- Failed auth always returns `identifiants invalides`
- Error body: `{code, message, details}`
- ETag on browse, assessment config, search suggestions
- If `CORS_ORIGINS` is `*`, credentials are off

## Flutter client

The Flutter app always uses this API (HTTP repositories only).

```bash
# API
cd backend && source .venv/bin/activate && uvicorn app.main:app --reload --port 8000

# App (iOS / desktop)
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api/v1

# Android emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

HTTP repos: auth, home, search, assessment, workouts, nutrition, stats, activities, coach, profile, settings.

## Tests

```bash
cd backend
source .venv/bin/activate
pytest -q
```

## Docker

```bash
cd backend
docker compose up --build
```

Postgres + Redis. Example:
`DATABASE_URL=postgresql+asyncpg://uplift:uplift@db:5432/uplift`

## Architecture

`router → service → repository → model`
