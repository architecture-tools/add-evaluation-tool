from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Sequence

from .entities import Component, Relationship


class PlantUMLParser(ABC):
    """Port for parsing PlantUML diagrams to extract components and relationships."""

    @abstractmethod
    def parse(self, content: str) -> tuple[Sequence[Component], Sequence[Relationship]]:
        """
        Parse PlantUML content and extract components and relationships.

        Args:
            content: Raw PlantUML file content

        Returns:
            Tuple of (components, relationships)

        Raises:
            ParseError: If the content cannot be parsed
        """
