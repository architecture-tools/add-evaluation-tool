from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Iterable, Optional, Sequence
from uuid import UUID

from .entities import Component, Diagram, Relationship


class DiagramRepository(ABC):
    """Repository abstraction for the Diagram aggregate."""

    @abstractmethod
    def add(self, diagram: Diagram) -> Diagram:
        """Persist a new diagram aggregate."""

    @abstractmethod
    def get(self, diagram_id: UUID) -> Optional[Diagram]:
        """Retrieve a diagram by its identifier."""

    @abstractmethod
    def list(self) -> Iterable[Diagram]:
        """Return all diagrams (temporary stub until pagination is added)."""

    @abstractmethod
    def find_by_checksum(self, checksum: str) -> Optional[Diagram]:
        """Retrieve a diagram by checksum to prevent duplicates."""

    @abstractmethod
    def add_components(self, components: Sequence[Component]) -> None:
        """Persist components for a diagram."""

    @abstractmethod
    def add_relationships(self, relationships: Sequence[Relationship]) -> None:
        """Persist relationships for a diagram."""

    @abstractmethod
    def get_components(self, diagram_id: UUID) -> Sequence[Component]:
        """Retrieve all components for a diagram."""

    @abstractmethod
    def get_relationships(self, diagram_id: UUID) -> Sequence[Relationship]:
        """Retrieve all relationships for a diagram."""
