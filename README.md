# Taka Taka — Turning Waste Into Worth

AI-powered geospatial waste intelligence and material traceability for Kenya.

**Pilot:** Kitui County (County 15)  
**Operational environment:** Kitui Municipality

## Stack

- Django + Django REST Framework
- PostgreSQL + PostGIS
- Redis + Celery
- React + TypeScript + Vite
- Docker Compose
- GitHub Actions

## Local development

```bash
cp .env.example .env
docker compose up --build
```

Backend: http://localhost:8000  
Frontend: http://localhost:5173

## Current milestone

Sprint 1 — Foundation:
- containerized backend/frontend/database/Redis
- Django health endpoint
- React application shell
- environment configuration
- initial domain app boundaries
- CI skeleton
