from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Iterable, Sequence
from uuid import UUID

from .entities import DiagramNFRComponentImpact, ImpactValue


class DiagramMatrixRepository(ABC):
    """Repository abstraction for NFR × Component impact matrix."""

    @abstractmethod
    def list_by_diagram(self, diagram_id: UUID) -> Sequence[DiagramNFRComponentImpact]:
        """Return all matrix entries for the diagram."""

    @abstractmethod
    def upsert(
        self,
        diagram_id: UUID,
        nfr_id: UUID,
        component_id: UUID,
        impact: ImpactValue,
    ) -> DiagramNFRComponentImpact:
        """Create or update a single matrix entry."""

    @abstractmethod
    def ensure_pairs(
        self,
        diagram_id: UUID,
        pairs: Iterable[tuple[UUID, UUID]],
        default_impact: ImpactValue = ImpactValue.NO_EFFECT,
    ) -> None:
        """Ensure that matrix entries exist for provided (nfr_id, component_id) pairs."""

    @abstractmethod
    def delete_missing_components(
        self, diagram_id: UUID, component_ids: Iterable[UUID]
    ) -> None:
        """Remove matrix entries for components that are no longer part of the diagram."""
