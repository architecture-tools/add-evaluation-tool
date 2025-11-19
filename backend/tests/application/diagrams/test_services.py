from __future__ import annotations

import pytest

from app.application.diagrams.ports import DiagramStorage
from app.application.diagrams.services import DiagramService
from app.domain.diagrams.entities import DiagramStatus
from app.domain.diagrams.exceptions import DiagramAlreadyExistsError, ParseError
from app.infrastructure.parsing.plantuml_parser import RegexPlantUMLParser
from app.infrastructure.persistence.in_memory import InMemoryDiagramRepository


class InMemoryStorage(DiagramStorage):
    """Simple in-memory storage stub for tests."""

    def __init__(self) -> None:
        self.saved: dict[str, bytes] = {}

    def save(self, content: bytes, filename: str) -> str:
        path = f"diagram://{filename}"
        self.saved[path] = content
        return path

    def read(self, path: str) -> bytes | None:
        return self.saved.get(path)


SAMPLE_PLANTUML = """
@startuml
[Frontend] as FE
[Backend] as BE
database "Main DB" as DB

FE --> BE : HTTP
BE --> DB : SQL
@enduml
""".strip()


@pytest.fixture()
def service() -> DiagramService:
    return DiagramService(
        repository=InMemoryDiagramRepository(),
        storage=InMemoryStorage(),
        parser=RegexPlantUMLParser(),
    )


def test_upload_diagram_persists_content_and_checksum(service: DiagramService) -> None:
    diagram = service.upload_diagram("demo.puml", SAMPLE_PLANTUML.encode(), display_name="Demo Diagram")
    stored = service.get_diagram(diagram.id)
    assert stored is not None
    assert stored.content == SAMPLE_PLANTUML
    assert stored.name == "Demo Diagram"
    assert stored.status == DiagramStatus.UPLOADED


def test_upload_diagram_prevents_duplicates(service: DiagramService) -> None:
    service.upload_diagram("demo.puml", SAMPLE_PLANTUML.encode())
    with pytest.raises(DiagramAlreadyExistsError):
        service.upload_diagram("demo.puml", SAMPLE_PLANTUML.encode())


def test_parse_diagram_updates_status_and_components(service: DiagramService) -> None:
    diagram = service.upload_diagram("demo.puml", SAMPLE_PLANTUML.encode())
    components, relationships = service.parse_diagram(diagram.id)

    assert len(components) == 3  # Frontend, Backend, Main DB
    assert len(relationships) == 2

    updated = service.get_diagram(diagram.id)
    assert updated is not None
    assert updated.status == DiagramStatus.PARSED
    assert updated.parsed_at is not None


def test_parse_diagram_failure_marks_diagram_failed(service: DiagramService) -> None:
    diagram = service.upload_diagram("empty.puml", b"")
    with pytest.raises(ParseError):
        service.parse_diagram(diagram.id)

    failed = service.get_diagram(diagram.id)
    assert failed is not None
    assert failed.status == DiagramStatus.FAILED

