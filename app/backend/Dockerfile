FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY app/backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app/backend/auth_server ./auth_server

EXPOSE 8000
CMD ["uvicorn", "auth_server.main:app", "--host", "0.0.0.0", "--port", "8000"]
