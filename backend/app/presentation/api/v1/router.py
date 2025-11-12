from fastapi import APIRouter

from .endpoints import health, diagrams

router = APIRouter()
router.include_router(health.router, tags=["health"])
router.include_router(diagrams.router, tags=["diagrams"])
