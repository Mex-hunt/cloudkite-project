from functools import lru_cache
import json
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = "CloudKite Auth Server"
    app_version: str = "0.1.0"
    environment: str = "local"
    log_level: str = "INFO"
    database_url: str = "sqlite:///./auth.db"
    database_credentials_file: str | None = None
    token_secret: str = "change-me-in-vault"
    token_ttl_seconds: int = 3600
    cors_origins: str = "http://localhost:5173"

    @property
    def cors_origin_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",") if origin.strip()]

    @property
    def resolved_database_url(self) -> str:
        if not self.database_credentials_file:
            return self.database_url
        credentials = json.loads(Path(self.database_credentials_file).read_text(encoding="utf-8"))
        return credentials["sqlalchemy_url"]

    @property
    def resolved_token_secret(self) -> str:
        if not self.database_credentials_file:
            return self.token_secret
        credentials = json.loads(Path(self.database_credentials_file).read_text(encoding="utf-8"))
        return credentials["token_secret"]


@lru_cache
def get_settings() -> Settings:
    return Settings()
