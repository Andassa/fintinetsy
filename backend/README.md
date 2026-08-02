# Uplift.ai API

FastAPI backend for the Fintinetsy / Uplift.ai Flutter app.

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

## Auth endpoints (`/api/v1/auth`)

| Method | Path | Auth |
|--------|------|------|
| POST | `/register` | public |
| POST | `/login` | public |
| POST | `/refresh` | public (refresh body) |
| POST | `/logout` | Bearer |
| GET | `/reset-methods` | public |
| POST | `/password-reset` | public |
| POST | `/password-reset/resend` | public |
| GET | `/me` | Bearer |

## Assessment / Users

| Method | Path | Auth |
|--------|------|------|
| GET | `/assessment/config` | public |
| GET | `/users/me` | Bearer |
| GET | `/users/me/assessment` | Bearer |
| PUT | `/users/me/assessment` | Bearer |

## Home

| Method | Path | Auth |
|--------|------|------|
| GET | `/home/dashboard` | Bearer |

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

Uses Postgres + Redis. Set `DATABASE_URL=postgresql+asyncpg://uplift:uplift@db:5432/uplift`.

## Architecture

`router → service → repository → model` (Clean Architecture).
