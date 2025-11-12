from __future__ import annotations

from pathlib import Path
from typing import Final
from uuid import uuid4

from app.application.diagrams.ports import DiagramStorage


class LocalDiagramStorage(DiagramStorage):
    def __init__(self, root: Path) -> None:
        self._root: Final[Path] = root
        self._root.mkdir(parents=True, exist_ok=True)

    def save(self, content: bytes, filename: str) -> str:
        extension = Path(filename).suffix or ".puml"
        target = self._root / f"{uuid4()}{extension}"
        target.write_bytes(content)
        return str(target.resolve())

    def read(self, path: str) -> bytes | None:
        file_path = Path(path)
        if not file_path.exists():
            return None
        return file_path.read_bytes()
