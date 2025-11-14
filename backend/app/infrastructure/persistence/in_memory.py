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

    def add_relationships(self, relationships: Sequence[Relationship]) -> None:
        for relationship in relationships:
            if relationship.diagram_id not in self._relationships:
                self._relationships[relationship.diagram_id] = []
            self._relationships[relationship.diagram_id].append(relationship)

    def get_components(self, diagram_id: UUID) -> Sequence[Component]:
        return self._components.get(diagram_id, [])

    def get_relationships(self, diagram_id: UUID) -> Sequence[Relationship]:
        return self._relationships.get(diagram_id, [])
