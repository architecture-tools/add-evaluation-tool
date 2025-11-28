from __future__ import annotations

from app.domain.diagrams.entities import ComponentType, RelationshipDirection
from app.infrastructure.parsing.plantuml_parser import RegexPlantUMLParser


def test_regex_parser_extracts_components_and_relationships() -> None:
    parser = RegexPlantUMLParser()
    content = """
    @startuml
    [Frontend] as FE
    [Backend] as BE
    queue "Message Bus" as BUS
    FE --> BE : HTTP
    BE <--> BUS : events
    @enduml
    """.strip()

    components, relationships = parser.parse(content)

    names = {component.name: component for component in components}
    assert {"Frontend", "Backend", "Message Bus"} == set(names)
    assert names["Message Bus"].type == ComponentType.QUEUE

    assert len(relationships) == 2
    assert relationships[0].direction == RelationshipDirection.UNIDIRECTIONAL
    assert relationships[1].direction == RelationshipDirection.BIDIRECTIONAL


def test_regex_parser_handles_participants_with_aliases() -> None:
    parser = RegexPlantUMLParser()
    content = """
    @startuml
    participant User
    participant "Browser UI" as UI
    participant API as BackendAPI
    User -> UI : clicks
    UI -> BackendAPI : request
    @enduml
    """.strip()

    components, relationships = parser.parse(content)

    names = {component.name: component for component in components}
    assert {"User", "Browser UI", "API"} == set(names)
    assert names["Browser UI"].type == ComponentType.INTERFACE
    assert len(relationships) == 2

