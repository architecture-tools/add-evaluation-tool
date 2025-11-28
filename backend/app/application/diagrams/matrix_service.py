from __future__ import annotations

from typing import Iterable, Sequence
from uuid import UUID

from collections import defaultdict

from app.domain.diagrams.entities import DiagramNFRComponentImpact, ImpactValue
from app.domain.diagrams.matrix_repository import DiagramMatrixRepository
from app.domain.diagrams.repositories import DiagramRepository
from app.domain.nfr.repositories import NonFunctionalRequirementRepository


class DiagramMatrixService:
    """Application service for managing diagram NFR × Component matrices."""

    def __init__(
        self,
        matrix_repository: DiagramMatrixRepository,
        nfr_repository: NonFunctionalRequirementRepository,
        diagram_repository: DiagramRepository,
    ) -> None:
        self._matrix_repository = matrix_repository
        self._nfr_repository = nfr_repository
        self._diagram_repository = diagram_repository

    _IMPACT_SCORES: dict[ImpactValue, int] = {
        ImpactValue.POSITIVE: 1,
        ImpactValue.NO_EFFECT: 0,
        ImpactValue.NEGATIVE: -1,
    }

    def list_matrix(self, diagram_id: UUID) -> Sequence[DiagramNFRComponentImpact]:
        return self._matrix_repository.list_by_diagram(diagram_id)

    def list_matrix_with_scores(
        self, diagram_id: UUID
    ) -> tuple[
        Sequence[DiagramNFRComponentImpact],
        dict[UUID, float],
        float | None,
    ]:
        entries = self._matrix_repository.list_by_diagram(diagram_id)
        aggregates: dict[UUID, list[int]] = defaultdict(lambda: [0, 0])
        for entry in entries:
            score = self._IMPACT_SCORES[entry.impact]
            aggregate = aggregates[entry.nfr_id]
            aggregate[0] += score
            aggregate[1] += 1

        averages: dict[UUID, float] = {}
        for nfr_id, (total, count) in aggregates.items():
            if count == 0:
                continue
            averages[nfr_id] = total / count

        overall_score: float | None = None
        if averages:
            overall_score = sum(averages.values()) / len(averages)

        return entries, averages, overall_score

    def update_impact(
        self,
        diagram_id: UUID,
        nfr_id: UUID,
        component_id: UUID,
        impact: ImpactValue,
    ) -> DiagramNFRComponentImpact:
        return self._matrix_repository.upsert(diagram_id, nfr_id, component_id, impact)

    def ensure_defaults(self, diagram_id: UUID) -> None:
        """Ensure that matrix entries exist for every NFR × Component combination."""
        components = self._diagram_repository.get_components(diagram_id)
        component_ids = [component.id for component in components]
        nfrs = self._nfr_repository.list()
        pairs: Iterable[tuple[UUID, UUID]] = (
            (nfr.id, component_id) for nfr in nfrs for component_id in component_ids
        )
        self._matrix_repository.ensure_pairs(diagram_id, pairs, ImpactValue.NO_EFFECT)
        self._matrix_repository.delete_missing_components(diagram_id, component_ids)
