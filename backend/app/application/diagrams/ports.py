from __future__ import annotations

from abc import ABC, abstractmethod


class DiagramStorage(ABC):
    @abstractmethod
    def save(self, content: bytes, filename: str) -> str:
        """Persist diagram source and return accessible path or URL."""

    @abstractmethod
    def read(self, path: str) -> bytes | None:
        """Read diagram content from storage path."""
