import json
import logging
import sqlite3
import sys
import uuid
from datetime import UTC, datetime

from fastapi import Depends, FastAPI, Header, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware

from auth_server.config import get_settings
from auth_server.database import db_session, init_db
from auth_server.metrics import metrics_middleware, metrics_response
from auth_server.schemas import AuthResponse, LoginRequest, RegisterRequest, TokenStatus, TokenVerifyRequest, UserResponse
from auth_server.security import create_token, decode_token, hash_password, verify_password

settings = get_settings()


class JsonFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        return json.dumps(
            {
                "timestamp": datetime.now(UTC).isoformat(),
                "level": record.levelname,
                "message": record.getMessage(),
                "logger": record.name,
            }
        )


handler = logging.StreamHandler(sys.stdout)
handler.setFormatter(JsonFormatter())
logging.basicConfig(level=settings.log_level.upper(), handlers=[handler], force=True)
logger = logging.getLogger("auth-server")

app = FastAPI(title=settings.app_name, version=settings.app_version)
app.middleware("http")(metrics_middleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origin_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def startup() -> None:
    init_db()
    logger.info("auth database initialized")


def bearer_token(authorization: str | None = Header(default=None)) -> str:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing bearer token")
    return authorization.split(" ", 1)[1]


def current_user(token: str = Depends(bearer_token)) -> sqlite3.Row:
    try:
        payload = decode_token(token)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(exc)) from exc

    with db_session() as db:
        revoked = db.execute("select token_id from revoked_tokens where token_id = ?", (payload["jti"],)).fetchone()
        if revoked:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token has been revoked")
        user = db.execute("select id, email, name from users where email = ?", (payload["sub"],)).fetchone()
        if user is None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
        return user


def auth_response(user: sqlite3.Row) -> AuthResponse:
    return AuthResponse(
        access_token=create_token(user["email"], user["name"]),
        expires_in=settings.token_ttl_seconds,
        user=UserResponse(id=user["id"], email=user["email"], name=user["name"]),
    )


@app.post("/auth/register", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
def register(payload: RegisterRequest) -> AuthResponse:
    with db_session() as db:
        try:
            db.execute(
                "insert into users (id, email, name, password_hash, created_at) values (?, ?, ?, ?, datetime('now'))",
                (f"usr_{uuid.uuid4().hex}", payload.email, payload.name, hash_password(payload.password)),
            )
        except sqlite3.IntegrityError as exc:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Email is already registered") from exc

        user = db.execute("select id, email, name from users where email = ?", (payload.email,)).fetchone()
        logger.info("user registered")
        return auth_response(user)


@app.post("/auth/login", response_model=AuthResponse)
def login(payload: LoginRequest) -> AuthResponse:
    with db_session() as db:
        user = db.execute("select * from users where email = ?", (payload.email,)).fetchone()
        if user is None or not verify_password(payload.password, user["password_hash"]):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")

        logger.info("user logged in")
        return auth_response(user)


@app.get("/auth/me", response_model=UserResponse)
def me(user: sqlite3.Row = Depends(current_user)) -> UserResponse:
    return UserResponse(id=user["id"], email=user["email"], name=user["name"])


@app.post("/auth/verify", response_model=TokenStatus)
def verify(payload: TokenVerifyRequest) -> TokenStatus:
    try:
        decoded = decode_token(payload.token)
    except ValueError as exc:
        return TokenStatus(active=False, reason=str(exc))

    with db_session() as db:
        revoked = db.execute("select token_id from revoked_tokens where token_id = ?", (decoded["jti"],)).fetchone()
        if revoked:
            return TokenStatus(active=False, reason="Token has been revoked")

    return TokenStatus(active=True, subject=decoded["sub"], expires_at=decoded["exp"])


@app.post("/auth/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(token: str = Depends(bearer_token)) -> None:
    decoded = decode_token(token)
    with db_session() as db:
        db.execute(
            "insert or ignore into revoked_tokens (token_id, revoked_at) values (?, datetime('now'))",
            (decoded["jti"],),
        )


@app.get("/healthz")
def healthz() -> dict[str, str]:
    return {"status": "ok", "version": settings.app_version}


@app.get("/readyz")
def readyz() -> dict[str, str]:
    with db_session() as db:
        db.execute("select 1")
    return {"status": "ready"}


@app.get("/metrics", include_in_schema=False)
def metrics():
    return metrics_response()
