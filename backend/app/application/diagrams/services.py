from __future__ import annotations

from hashlib import sha256
from typing import Iterable
from uuid import UUID

from app.domain.diagrams.entities import Component, Diagram, Relationship
from app.domain.diagrams.exceptions import DiagramAlreadyExistsError, DiagramNotFoundError, ParseError
from app.domain.diagrams.parsers import PlantUMLParser
from app.domain.diagrams.repositories import DiagramRepository

from .ports import DiagramStorage


class DiagramService:
    def __init__(
        self,
        repository: DiagramRepository,
        storage: DiagramStorage,
        parser: PlantUMLParser,
    ) -> None:
        self._repository = repository
        self._storage = storage
        self._parser = parser

    def register_diagram(self, diagram: Diagram) -> Diagram:
        return self._repository.add(diagram)

    def get_diagram(self, diagram_id: UUID) -> Diagram | None:
        return self._repository.get(diagram_id)

    def list_diagrams(self) -> Iterable[Diagram]:
        return self._repository.list()

    def upload_diagram(
        self, filename: str, content: bytes, display_name: str | None = None
    ) -> Diagram:
        checksum = sha256(content).hexdigest()
        existing = self._repository.find_by_checksum(checksum)
        if existing:
            raise DiagramAlreadyExistsError(existing.id)

        storage_path = self._storage.save(content, filename)

        diagram = Diagram(
            name=display_name or filename,
            source_url=storage_path,
            checksum=checksum,
        )
        return self._repository.add(diagram)

    def parse_diagram(self, diagram_id: UUID) -> tuple[list[Component], list[Relationship]]:
        diagram = self._repository.get(diagram_id)
        if not diagram:
            raise DiagramNotFoundError(f"Diagram {diagram_id} not found")

        # Read file content
        content = self._storage.read(diagram.source_url)
        if not content:
            raise ParseError(f"Could not read diagram file: {diagram.source_url}")

        # Parse content
        try:
            components, relationships = self._parser.parse(content.decode("utf-8"))
        except Exception as exc:
            diagram.mark_failed()
            self._repository.add(diagram)
            raise ParseError(f"Failed to parse diagram: {exc}") from exc

        # Set diagram_id for all components and relationships
        for component in components:
            component.diagram_id = diagram_id

        for relationship in relationships:
            relationship.diagram_id = diagram_id

        # Persist components and relationships
        self._repository.add_components(components)
        self._repository.add_relationships(relationships)

        # Update diagram status
        diagram.mark_parsed()
        self._repository.add(diagram)

        return list(components), list(relationships)
