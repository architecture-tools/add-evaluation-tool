from functools import lru_cache

from app.application.diagrams.services import DiagramService
from app.core.config import get_settings
from app.infrastructure.parsing.plantuml_parser import RegexPlantUMLParser
from app.infrastructure.persistence.in_memory import InMemoryDiagramRepository
from app.infrastructure.storage.local import LocalDiagramStorage


@lru_cache
def get_diagram_repository() -> InMemoryDiagramRepository:
    return InMemoryDiagramRepository()


@lru_cache
def get_diagram_storage() -> LocalDiagramStorage:
    settings = get_settings()
    storage_path = settings.storage_root / "diagrams"
    return LocalDiagramStorage(storage_path)


@lru_cache
def get_plantuml_parser() -> RegexPlantUMLParser:
    return RegexPlantUMLParser()


@lru_cache
def get_diagram_service() -> DiagramService:
    return DiagramService(
        get_diagram_repository(),
        get_diagram_storage(),
        get_plantuml_parser(),
    )
