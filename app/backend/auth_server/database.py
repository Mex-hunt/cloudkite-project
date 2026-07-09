from collections.abc import Generator
from contextlib import contextmanager

from sqlalchemy import Column, DateTime, MetaData, String, Table, create_engine
from sqlalchemy.engine import Connection

from auth_server.config import get_settings

metadata = MetaData()

users = Table(
    "users",
    metadata,
    Column("id", String(64), primary_key=True),
    Column("email", String(320), unique=True, nullable=False),
    Column("name", String(80), nullable=False),
    Column("password_hash", String(255), nullable=False),
    Column("created_at", DateTime(timezone=True), nullable=False),
)

revoked_tokens = Table(
    "revoked_tokens",
    metadata,
    Column("token_id", String(255), primary_key=True),
    Column("revoked_at", DateTime(timezone=True), nullable=False),
)

database_url = get_settings().resolved_database_url
connect_args = {"check_same_thread": False} if database_url.startswith("sqlite") else {}
engine = create_engine(database_url, pool_pre_ping=True, connect_args=connect_args)


@contextmanager
def db_session() -> Generator[Connection, None, None]:
    with engine.begin() as connection:
        yield connection


def init_db() -> None:
    # Local SQLite remains zero-setup; deployed databases are migrated by Alembic.
    if database_url.startswith("sqlite"):
        metadata.create_all(engine)
