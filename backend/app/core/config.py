from functools import lru_cache
from pathlib import Path
from typing import Any, Dict, List, Optional, Union

from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


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

    # DATABASE_URL is automatically read from environment variables
    # Render.com provides this when PostgreSQL service is linked to backend service
    # Pydantic Settings automatically reads DATABASE_URL (case-insensitive)
    database_url: str = (
        "postgresql://arch_eval:arch_eval_password@localhost:5432/arch_eval_db"
    )

    # JWT Authentication settings
    jwt_secret_key: str = "your-secret-key-change-in-production"
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 30

    # Telemetry settings (disabled by default)
    telemetry_enabled: bool = False
    telemetry_traces_enabled: bool = False
    telemetry_metrics_enabled: bool = False
    telemetry_logs_enabled: bool = False
    telemetry_service_name: str = "architecture-evaluation-tool"
    telemetry_service_namespace: str = "backend"
    telemetry_otlp_endpoint: Optional[str] = None
    telemetry_otlp_headers: Optional[Union[Dict[str, str], str]] = None
    telemetry_otlp_insecure: bool = False

    @field_validator("telemetry_otlp_headers", mode="before")
    @classmethod
    def parse_headers(cls, v: Any) -> Optional[Dict[str, str]]:
        """Parse headers from string format (JSON or URL-encoded) to dict."""
        if v is None:
            return {}
        if isinstance(v, dict):
            return v
        if isinstance(v, str):
            import json
            from urllib.parse import unquote, parse_qs

            # Try JSON format first: {"Authorization": "Basic ..."}
            try:
                return json.loads(v)
            except (json.JSONDecodeError, ValueError):
                # Try URL-encoded format: Authorization=Basic%20...
                # This is the format Grafana Cloud provides
                try:
                    # URL decode and parse as query string
                    decoded = unquote(v)
                    parsed = parse_qs(decoded, keep_blank_values=True)
                    # Convert to dict format expected by OTLP exporter
                    result: Dict[str, str] = {}
                    for k, v in parsed.items():
                        if isinstance(v, list) and len(v) > 0:
                            result[k] = v[0]
                        else:
                            result[k] = str(v)
                    return result
                except Exception:
                    # If both fail, treat as single header value
                    # Format: "Authorization=Basic ..." -> {"Authorization": "Basic ..."}
                    if "=" in v:
                        key, value = v.split("=", 1)
                        return {key: unquote(value)}
                    return {}
        return {}

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        # This ensures DATABASE_URL from environment overrides the default
        env_prefix="",  # No prefix needed, read DATABASE_URL directly
    )


@lru_cache(1)
def get_settings() -> Settings:
    return Settings()
