from fastapi import APIRouter

from .endpoints import health, diagrams, nfrs

router = APIRouter()
router.include_router(health.router, tags=["health"])
router.include_router(diagrams.router, tags=["diagrams"])
router.include_router(nfrs.router, tags=["nfr"])
