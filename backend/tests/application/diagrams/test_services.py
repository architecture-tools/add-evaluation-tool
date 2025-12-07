from __future__ import annotations

import pytest

from app.application.diagrams.ports import DiagramStorage
from app.application.diagrams.services import DiagramService
from app.domain.diagrams.entities import DiagramStatus, RelationshipDirection
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


def test_diff_diagrams_returns_component_and_relationship_changes(
    service: DiagramService,
) -> None:
    base_content = """
    @startuml
    [Frontend] as FE
    [Backend] as BE
    database "Main DB" as DB

    FE --> BE : HTTP
    BE --> DB : SQL
    @enduml
    """.strip()

    target_content = """
    @startuml
    [Frontend] as FE
    [Backend] as BE
    database "Main DB" as DB
    queue "Cache" as CACHE

    FE --> BE : HTTP
    BE --> DB : SQL(read)
    BE --> CACHE : cache
    @enduml
    """.strip()

    base = service.upload_diagram("base.puml", base_content.encode())
    target = service.upload_diagram("target.puml", target_content.encode())

    service.parse_diagram(base.id)
    service.parse_diagram(target.id)

    component_diffs, relationship_diffs = service.diff_diagrams(
        base_diagram_id=base.id, target_diagram_id=target.id
    )

    added_components = [diff for diff in component_diffs if diff.change_type == "added"]
    assert len(added_components) == 1
    assert added_components[0].name == "Cache"

    modified_relationships = [
        diff for diff in relationship_diffs if diff.change_type == "modified"
    ]
    assert len(modified_relationships) == 1
    assert modified_relationships[0].source == "Backend"
    assert modified_relationships[0].target == "Main DB"
    assert modified_relationships[0].previous_label == "SQL"
    assert modified_relationships[0].new_label == "SQL(read)"
    assert (
        modified_relationships[0].previous_direction
        == RelationshipDirection.UNIDIRECTIONAL
    )
    assert (
        modified_relationships[0].new_direction
        == RelationshipDirection.UNIDIRECTIONAL
    )

    added_relationships = [
        diff for diff in relationship_diffs if diff.change_type == "added"
    ]
    assert any(
        rel.source == "Backend"
        and rel.target == "Cache"
        and rel.new_label == "cache"
        for rel in added_relationships
    )

