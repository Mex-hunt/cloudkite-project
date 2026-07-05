import sqlite3
from collections.abc import Generator
from contextlib import contextmanager
from pathlib import Path

from auth_server.config import get_settings
def connect() -> sqlite3.Connection:
    settings = get_settings()
    Path(settings.database_path).parent.mkdir(parents=True, exist_ok=True)
    connection = sqlite3.connect(settings.database_path)
    connection.row_factory = sqlite3.Row
    return connection


@contextmanager
def db_session() -> Generator[sqlite3.Connection, None, None]:
    connection = connect()
    try:
        yield connection
        connection.commit()
    finally:
        connection.close()


def init_db() -> None:
    with db_session() as db:
        db.execute(
            """
            create table if not exists users (
              id text primary key,
              email text unique not null,
              name text not null,
              password_hash text not null,
              created_at text not null
            )
            """
        )
        db.execute(
            """
            create table if not exists revoked_tokens (
              token_id text primary key,
              revoked_at text not null
            )
            """
        )
