from __future__ import annotations

from hashlib import sha256
from typing import Iterable, Dict, Sequence
from uuid import UUID, uuid5

from app.domain.diagrams.entities import Component, Diagram, Relationship
from app.domain.diagrams.exceptions import (
    DiagramAlreadyExistsError,
    DiagramNotFoundError,
    ParseError,
)
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
        content_str = content.decode("utf-8")
        checksum = sha256(content).hexdigest()
        existing = self._repository.find_by_checksum(checksum)
        if existing:
            raise DiagramAlreadyExistsError(existing.id)

        # Store content in DB, source_url is now just a reference/identifier
        source_url = f"diagram://{filename}"

        diagram = Diagram(
            name=display_name or filename,
            source_url=source_url,
            content=content_str,
            checksum=checksum,
        )
        return self._repository.add(diagram)

    def parse_diagram(
        self, diagram_id: UUID
    ) -> tuple[list[Component], list[Relationship]]:
        diagram = self._repository.get(diagram_id)
        if not diagram:
            raise DiagramNotFoundError(f"Diagram {diagram_id} not found")

        # Read content from diagram (stored in DB)
        if not diagram.content:
            diagram.mark_failed()
            self._repository.update(diagram)
            raise ParseError(f"Diagram {diagram_id} has no content")

        # Parse content
        try:
            components, relationships = self._parser.parse(diagram.content)
        except Exception as exc:
            diagram.mark_failed()
            self._repository.update(diagram)
            raise ParseError(f"Failed to parse diagram: {exc}") from exc

        for component in components:
            component.diagram_id = diagram_id

        id_mapping = self._sync_components(diagram_id, components)

        for relationship in relationships:
            relationship.diagram_id = diagram_id
            if relationship.source_component_id in id_mapping:
                relationship.source_component_id = id_mapping[
                    relationship.source_component_id
                ]
            if relationship.target_component_id in id_mapping:
                relationship.target_component_id = id_mapping[
                    relationship.target_component_id
                ]

        # Replace relationships atomically (components are upserted)
        self._repository.delete_relationships(diagram_id)
        self._repository.add_relationships(relationships)

        # Update diagram status
        diagram.mark_parsed()
        self._repository.update(diagram)

        return list(components), list(relationships)

    def _sync_components(
        self, diagram_id: UUID, components: Sequence[Component]
    ) -> Dict[UUID, UUID]:
        existing_components = self._repository.get_components(diagram_id)
        existing_by_name = {
            self._normalize_name(component.name): component
            for component in existing_components
        }

        final_ids: set[UUID] = set()
        components_to_add: list[Component] = []
        components_to_update: list[Component] = []
        id_mapping: Dict[UUID, UUID] = {}

        for component in components:
            original_id = component.id
            normalized_name = self._normalize_name(component.name)
            if normalized_name in existing_by_name:
                existing = existing_by_name[normalized_name]
                component.id = existing.id
                final_ids.add(existing.id)
                id_mapping[original_id] = existing.id

                if (
                    existing.name != component.name
                    or existing.type != component.type
                    or existing.metadata != component.metadata
                ):
                    components_to_update.append(component)
            else:
                stable_id = self._stable_component_id(diagram_id, component)
                component.id = stable_id
                final_ids.add(stable_id)
                id_mapping[original_id] = stable_id
                components_to_add.append(component)

        obsolete_ids = [
            component.id
            for component in existing_components
            if component.id not in final_ids
        ]

        if obsolete_ids:
            self._repository.delete_components(diagram_id, obsolete_ids)

        if components_to_add:
            self._repository.add_components(components_to_add)

        if components_to_update:
            self._repository.update_components(components_to_update)

        return id_mapping

    @staticmethod
    def _stable_component_id(diagram_id: UUID, component: Component) -> UUID:
        """Return deterministic UUID per diagram/component name+type."""
        key = f"{component.name.strip().lower()}::{component.type.value}"
        return uuid5(diagram_id, key)

    @staticmethod
    def _normalize_name(name: str) -> str:
        return " ".join(name.split()).lower()
