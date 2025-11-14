from functools import lru_cache
from pathlib import Path
from typing import List

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "Architecture Evaluation Tool API"
    app_description: str = "Backend API for architecture evaluation"
    app_version: str = "0.1.0"

    api_prefix: str = "/api"
    docs_url: str | None = "/docs"
    openapi_url: str | None = "/openapi.json"

    cors_allow_origins: List[str] = ["*"]
    cors_allow_credentials: bool = True
    cors_allow_methods: List[str] = ["*"]
    cors_allow_headers: List[str] = ["*"]

    storage_root: Path = Path("storage")

    database_url: str = "postgresql://arch_eval:arch_eval_password@localhost:5432/arch_eval_db"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache(1)
def get_settings() -> Settings:
    return Settings()
