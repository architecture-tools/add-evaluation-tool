from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Iterable, Optional
from uuid import UUID

from .entities import NonFunctionalRequirement


class NonFunctionalRequirementRepository(ABC):
    """Abstraction for storing non-functional requirements."""

    @abstractmethod
    def add(self, nfr: NonFunctionalRequirement) -> NonFunctionalRequirement:
        """Persist a new NFR record."""

    @abstractmethod
    def get(self, nfr_id: UUID) -> Optional[NonFunctionalRequirement]:
        """Fetch NFR by identifier."""

    @abstractmethod
    def get_by_name(self, name: str) -> Optional[NonFunctionalRequirement]:
        """Fetch NFR by its unique name."""

    @abstractmethod
    def list(self) -> Iterable[NonFunctionalRequirement]:
        """List all NFRs."""

    @abstractmethod
    def delete(self, nfr_id: UUID) -> None:
        """Delete NFR by identifier."""
