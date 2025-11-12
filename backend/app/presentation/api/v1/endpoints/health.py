from fastapi import APIRouter

from app.application.system.services import HealthService

router = APIRouter()


@router.get("/health", summary="Health check")
async def health_check() -> dict[str, str]:
    return HealthService.get_health_status()
