from __future__ import annotations

from typing import Dict, Iterable, List, Optional, Sequence
from uuid import UUID

from app.domain.diagrams.entities import Component, Diagram, Relationship
from app.domain.diagrams.repositories import DiagramRepository


class InMemoryDiagramRepository(DiagramRepository):
    def __init__(self) -> None:
        self._store: Dict[UUID, Diagram] = {}
        self._by_checksum: Dict[str, UUID] = {}
        self._components: Dict[UUID, List[Component]] = {}
        self._relationships: Dict[UUID, List[Relationship]] = {}

    def add(self, diagram: Diagram) -> Diagram:
        self._store[diagram.id] = diagram
        self._by_checksum[diagram.checksum] = diagram.id
        return diagram

    def update(self, diagram: Diagram) -> Diagram:
        if diagram.id not in self._store:
            raise ValueError(f"Diagram {diagram.id} does not exist")
        self._store[diagram.id] = diagram
        self._by_checksum[diagram.checksum] = diagram.id
        return diagram

    def get(self, diagram_id: UUID) -> Optional[Diagram]:
        return self._store.get(diagram_id)

    def list(self) -> Iterable[Diagram]:
        return list(self._store.values())

    def find_by_checksum(self, checksum: str) -> Optional[Diagram]:
        diagram_id = self._by_checksum.get(checksum)
        if diagram_id is None:
            return None
        return self._store.get(diagram_id)

    def add_components(self, components: Sequence[Component]) -> None:
        for component in components:
            if component.diagram_id not in self._components:
                self._components[component.diagram_id] = []
            self._components[component.diagram_id].append(component)

    def update_components(self, components: Sequence[Component]) -> None:
        for component in components:
            diagram_components = self._components.setdefault(component.diagram_id, [])
            for idx, existing in enumerate(diagram_components):
                if existing.id == component.id:
                    diagram_components[idx] = component
                    break

    def delete_components(
        self, diagram_id: UUID, component_ids: Iterable[UUID] | None = None
    ) -> None:
        if component_ids is None:
            self._components.pop(diagram_id, None)
            return

        ids_to_keep = set(component_ids)
        if not ids_to_keep:
            self._components.pop(diagram_id, None)
            return

        diagram_components = self._components.get(diagram_id, [])
        self._components[diagram_id] = [
            component for component in diagram_components if component.id in ids_to_keep
        ]

    def add_relationships(self, relationships: Sequence[Relationship]) -> None:
        for relationship in relationships:
            if relationship.diagram_id not in self._relationships:
                self._relationships[relationship.diagram_id] = []
            self._relationships[relationship.diagram_id].append(relationship)

    def delete_relationships(self, diagram_id: UUID) -> None:
        self._relationships.pop(diagram_id, None)

    def get_components(self, diagram_id: UUID) -> Sequence[Component]:
        return self._components.get(diagram_id, [])

    def get_relationships(self, diagram_id: UUID) -> Sequence[Relationship]:
        return self._relationships.get(diagram_id, [])
