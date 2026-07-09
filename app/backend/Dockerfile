FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DEFAULT_TIMEOUT=120 \
    PIP_RETRIES=5

WORKDIR /app

COPY app/backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/backend/auth_server ./auth_server
COPY app/backend/alembic.ini .
COPY app/backend/migrations ./migrations

EXPOSE 8000
CMD ["sh", "-c", "alembic upgrade head && exec uvicorn auth_server.main:app --host 0.0.0.0 --port 8000"]
