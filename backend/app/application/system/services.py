from __future__ import annotations

from datetime import datetime

from app.core.config import get_settings


class HealthService:
    @staticmethod
    def get_health_status() -> dict[str, str]:
        settings = get_settings()
        return {
            "status": "healthy",
            "app": settings.app_name,
            "version": settings.app_version,
            "timestamp": datetime.utcnow().isoformat() + "Z",
        }
