from __future__ import annotations

from collections import defaultdict
from typing import Iterable, Sequence
from uuid import uuid4, UUID

from app.application.diagrams.matrix_service import DiagramMatrixService
from app.domain.diagrams.entities import (
    Component,
    ComponentType,
    Diagram,
    DiagramNFRComponentImpact,
    ImpactValue,
)
from app.domain.diagrams.matrix_repository import DiagramMatrixRepository
from app.domain.diagrams.repositories import DiagramRepository
from app.domain.nfr.entities import NonFunctionalRequirement
from app.domain.nfr.repositories import NonFunctionalRequirementRepository


class InMemoryDiagramRepository(DiagramRepository):
    def __init__(self) -> None:
        self.diagram = Diagram(
            name="test",
            source_url="diagram://test",
            content="[]",
            checksum="test",
        )
        self.components: list[Component] = [
            Component(
                diagram_id=self.diagram.id,
                name="Component A",
                type=ComponentType.COMPONENT,
            ),
            Component(
                diagram_id=self.diagram.id,
                name="Component B",
                type=ComponentType.DATABASE,
            ),
        ]

    def add(self, diagram: Diagram) -> Diagram:
        self.diagram = diagram
        return diagram

    def update(self, diagram: Diagram) -> Diagram:
        self.diagram = diagram
        return diagram

    def get(self, diagram_id: UUID) -> Diagram | None:
        return self.diagram if self.diagram.id == diagram_id else None

    def list(self) -> Sequence[Diagram]:
        return [self.diagram]

    def find_by_checksum(self, checksum: str) -> Diagram | None:
        return self.diagram if self.diagram.checksum == checksum else None

    def add_components(self, components: Sequence[Component]) -> None:
        self.components.extend(components)

    def add_relationships(self, relationships):
        return None

    def get_components(self, diagram_id: UUID) -> Sequence[Component]:
        return list(self.components)

    def get_relationships(self, diagram_id: UUID):
        return []


class InMemoryNFRRepository(NonFunctionalRequirementRepository):
    def __init__(self) -> None:
        self.items = [
            NonFunctionalRequirement(name="Performance"),
            NonFunctionalRequirement(name="Security"),
        ]

    def add(self, nfr: NonFunctionalRequirement) -> NonFunctionalRequirement:
        self.items.append(nfr)
        return nfr

    def get(self, nfr_id: UUID) -> NonFunctionalRequirement | None:
        return next((nfr for nfr in self.items if nfr.id == nfr_id), None)

    def get_by_name(self, name: str) -> NonFunctionalRequirement | None:
        return next((nfr for nfr in self.items if nfr.name == name), None)

    def list(self) -> Sequence[NonFunctionalRequirement]:
        return list(self.items)

    def delete(self, nfr_id: UUID) -> None:
        self.items = [nfr for nfr in self.items if nfr.id != nfr_id]


class InMemoryMatrixRepository(DiagramMatrixRepository):
    def __init__(self) -> None:
        self.entries: dict[tuple[UUID, UUID, UUID], DiagramNFRComponentImpact] = {}

    def list_by_diagram(self, diagram_id: UUID) -> Sequence[DiagramNFRComponentImpact]:
        return [
            entry
            for key, entry in self.entries.items()
            if entry.diagram_id == diagram_id
        ]

    def upsert(
        self,
        diagram_id: UUID,
        nfr_id: UUID,
        component_id: UUID,
        impact: ImpactValue,
    ) -> DiagramNFRComponentImpact:
        key = (diagram_id, nfr_id, component_id)
        entry = self.entries.get(key)
        if entry is None:
            entry = DiagramNFRComponentImpact(
                diagram_id=diagram_id,
                nfr_id=nfr_id,
                component_id=component_id,
                impact=impact,
            )
        else:
            entry.impact = impact
        self.entries[key] = entry
        return entry

    def ensure_pairs(
        self,
        diagram_id: UUID,
        pairs: Iterable[tuple[UUID, UUID]],
        default_impact: ImpactValue = ImpactValue.NO_EFFECT,
    ) -> None:
        for nfr_id, component_id in pairs:
            key = (diagram_id, nfr_id, component_id)
            if key not in self.entries:
                self.entries[key] = DiagramNFRComponentImpact(
                    diagram_id=diagram_id,
                    nfr_id=nfr_id,
                    component_id=component_id,
                    impact=default_impact,
                )

    def delete_missing_components(
        self, diagram_id: UUID, component_ids: Iterable[UUID]
    ) -> None:
        component_set = set(component_ids)
        self.entries = {
            key: value
            for key, value in self.entries.items()
            if value.diagram_id != diagram_id
            or (component_set and value.component_id in component_set)
        }


def test_ensure_defaults_creates_missing_entries() -> None:
    diagram_repo = InMemoryDiagramRepository()
    nfr_repo = InMemoryNFRRepository()
    matrix_repo = InMemoryMatrixRepository()
    service = DiagramMatrixService(matrix_repo, nfr_repo, diagram_repo)

    service.ensure_defaults(diagram_repo.diagram.id)

    entries = matrix_repo.list_by_diagram(diagram_repo.diagram.id)
    assert len(entries) == len(diagram_repo.components) * len(nfr_repo.items)
    assert all(entry.impact == ImpactValue.NO_EFFECT for entry in entries)


def test_update_impact_changes_value() -> None:
    diagram_repo = InMemoryDiagramRepository()
    nfr_repo = InMemoryNFRRepository()
    matrix_repo = InMemoryMatrixRepository()
    service = DiagramMatrixService(matrix_repo, nfr_repo, diagram_repo)

    service.ensure_defaults(diagram_repo.diagram.id)
    entry = service.update_impact(
        diagram_repo.diagram.id,
        nfr_repo.items[0].id,
        diagram_repo.components[0].id,
        ImpactValue.POSITIVE,
    )

    assert entry.impact == ImpactValue.POSITIVE


def test_list_matrix_with_scores_returns_averages_and_overall_score() -> None:
    diagram_repo = InMemoryDiagramRepository()
    nfr_repo = InMemoryNFRRepository()
    matrix_repo = InMemoryMatrixRepository()
    service = DiagramMatrixService(matrix_repo, nfr_repo, diagram_repo)

    service.ensure_defaults(diagram_repo.diagram.id)
    service.update_impact(
        diagram_repo.diagram.id,
        nfr_repo.items[0].id,
        diagram_repo.components[0].id,
        ImpactValue.POSITIVE,
    )
    service.update_impact(
        diagram_repo.diagram.id,
        nfr_repo.items[0].id,
        diagram_repo.components[1].id,
        ImpactValue.NEGATIVE,
    )
    entries, scores, overall = service.list_matrix_with_scores(
        diagram_repo.diagram.id
    )

    assert len(entries) == len(diagram_repo.components) * len(nfr_repo.items)
    assert scores[nfr_repo.items[0].id] == 0
    assert scores[nfr_repo.items[1].id] == 0
    assert overall == 0
