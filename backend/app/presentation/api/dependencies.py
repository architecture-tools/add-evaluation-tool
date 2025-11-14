from functools import lru_cache

from fastapi import Depends
from sqlalchemy.orm import Session

from app.application.diagrams.services import DiagramService
from app.core.config import get_settings
from app.domain.diagrams.repositories import DiagramRepository
from app.infrastructure.parsing.plantuml_parser import RegexPlantUMLParser
from app.infrastructure.persistence.database import get_db
from app.infrastructure.persistence.postgresql import PostgreSQLDiagramRepository
from app.infrastructure.storage.local import LocalDiagramStorage


def get_diagram_repository(db: Session = Depends(get_db)) -> DiagramRepository:
    """Get diagram repository with database session."""
    return PostgreSQLDiagramRepository(db)


@lru_cache
def get_diagram_storage() -> LocalDiagramStorage:
    settings = get_settings()
    storage_path = settings.storage_root / "diagrams"
    return LocalDiagramStorage(storage_path)


@lru_cache
def get_plantuml_parser() -> RegexPlantUMLParser:
    return RegexPlantUMLParser()


def get_diagram_service(
    repository: DiagramRepository = Depends(get_diagram_repository),
    storage: LocalDiagramStorage = Depends(get_diagram_storage),
    parser: RegexPlantUMLParser = Depends(get_plantuml_parser),
) -> DiagramService:
    """Get diagram service with dependencies."""
    return DiagramService(
        repository,
        storage,
        parser,
    )
