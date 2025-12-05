from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
from typing import Dict, Iterable, Literal, Sequence
from uuid import UUID, uuid5

from app.domain.diagrams.entities import (
    Component,
    ComponentType,
    Diagram,
    Relationship,
    RelationshipDirection,
)
from app.domain.diagrams.exceptions import (
    DiagramAlreadyExistsError,
    DiagramNotFoundError,
    ParseError,
)
from app.domain.diagrams.parsers import PlantUMLParser
from app.domain.diagrams.repositories import DiagramRepository

from .ports import DiagramStorage


@dataclass(slots=True)
class ComponentDiff:
    name: str
    change_type: Literal["added", "removed", "modified"]
    previous_type: ComponentType | None = None
    new_type: ComponentType | None = None


@dataclass(slots=True)
class RelationshipDiff:
    source: str
    target: str
    change_type: Literal["added", "removed", "modified"]
    previous_label: str | None = None
    new_label: str | None = None
    previous_direction: RelationshipDirection | None = None
    new_direction: RelationshipDirection | None = None


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

    def diff_diagrams(
        self, base_diagram_id: UUID, target_diagram_id: UUID
    ) -> tuple[list[ComponentDiff], list[RelationshipDiff]]:
        base = self._repository.get(base_diagram_id)
        target = self._repository.get(target_diagram_id)
        if base is None or target is None:
            missing_id = base_diagram_id if base is None else target_diagram_id
            raise DiagramNotFoundError(f"Diagram {missing_id} not found")

        base_components = self._repository.get_components(base_diagram_id)
        target_components = self._repository.get_components(target_diagram_id)

        components_diff = self._build_component_diff(
            base_components=base_components, target_components=target_components
        )

        base_relationships = self._repository.get_relationships(base_diagram_id)
        target_relationships = self._repository.get_relationships(target_diagram_id)

        relationships_diff = self._build_relationship_diff(
            base_components=base_components,
            target_components=target_components,
            base_relationships=base_relationships,
            target_relationships=target_relationships,
        )

        return components_diff, relationships_diff

    def _build_component_diff(
        self,
        base_components: Sequence[Component],
        target_components: Sequence[Component],
    ) -> list[ComponentDiff]:
        base_by_name = {
            self._normalize_name(component.name): component
            for component in base_components
        }
        target_by_name = {
            self._normalize_name(component.name): component
            for component in target_components
        }

        diffs: list[ComponentDiff] = []

        # Added or modified
        for name_key, target_component in target_by_name.items():
            if name_key not in base_by_name:
                diffs.append(
                    ComponentDiff(
                        name=target_component.name,
                        change_type="added",
                        new_type=target_component.type,
                    )
                )
                continue

            base_component = base_by_name[name_key]
            if base_component.type != target_component.type:
                diffs.append(
                    ComponentDiff(
                        name=target_component.name,
                        change_type="modified",
                        previous_type=base_component.type,
                        new_type=target_component.type,
                    )
                )

        # Removed
        for name_key, base_component in base_by_name.items():
            if name_key not in target_by_name:
                diffs.append(
                    ComponentDiff(
                        name=base_component.name,
                        change_type="removed",
                        previous_type=base_component.type,
                    )
                )

        return diffs

    def _build_relationship_diff(
        self,
        base_components: Sequence[Component],
        target_components: Sequence[Component],
        base_relationships: Sequence[Relationship],
        target_relationships: Sequence[Relationship],
    ) -> list[RelationshipDiff]:
        base_names_by_id = {
            component.id: component.name for component in base_components
        }
        target_names_by_id = {
            component.id: component.name for component in target_components
        }

        def _relationship_key(source_name: str, target_name: str) -> tuple[str, str]:
            return (
                self._normalize_name(source_name),
                self._normalize_name(target_name),
            )

        base_by_key: dict[tuple[str, str], Relationship] = {}
        for relationship in base_relationships:
            source_name = base_names_by_id.get(relationship.source_component_id)
            target_name = base_names_by_id.get(relationship.target_component_id)
            if source_name and target_name:
                base_by_key[_relationship_key(source_name, target_name)] = relationship

        diffs: list[RelationshipDiff] = []

        for relationship in target_relationships:
            source_name = target_names_by_id.get(relationship.source_component_id)
            target_name = target_names_by_id.get(relationship.target_component_id)
            if not source_name or not target_name:
                continue

            key = _relationship_key(source_name, target_name)
            if key not in base_by_key:
                diffs.append(
                    RelationshipDiff(
                        source=source_name,
                        target=target_name,
                        change_type="added",
                        new_label=relationship.label,
                        new_direction=relationship.direction,
                    )
                )
                continue

            base_relationship = base_by_key.pop(key)
            if (
                base_relationship.label != relationship.label
                or base_relationship.direction != relationship.direction
            ):
                diffs.append(
                    RelationshipDiff(
                        source=source_name,
                        target=target_name,
                        change_type="modified",
                        previous_label=base_relationship.label,
                        new_label=relationship.label,
                        previous_direction=base_relationship.direction,
                        new_direction=relationship.direction,
                    )
                )

        # Relationships removed from target
        for key, relationship in base_by_key.items():
            source_name = base_names_by_id.get(relationship.source_component_id)
            target_name = base_names_by_id.get(relationship.target_component_id)
            if source_name and target_name:
                diffs.append(
                    RelationshipDiff(
                        source=source_name,
                        target=target_name,
                        change_type="removed",
                        previous_label=relationship.label,
                        previous_direction=relationship.direction,
                    )
                )

        return diffs
