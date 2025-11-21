from __future__ import annotations

from uuid import UUID

from app.domain.nfr.entities import NonFunctionalRequirement
from app.domain.nfr.exceptions import NFRAlreadyExistsError, NFRNotFoundError
from app.domain.nfr.repositories import NonFunctionalRequirementRepository


class NFRService:
    """Application service encapsulating NFR management use cases."""

    def __init__(self, repository: NonFunctionalRequirementRepository) -> None:
        self._repository = repository

    def list_requirements(self) -> list[NonFunctionalRequirement]:
        return list(self._repository.list())

    def create_requirement(
        self, name: str, description: str | None = None
    ) -> NonFunctionalRequirement:
        existing = self._repository.get_by_name(name)
        if existing:
            raise NFRAlreadyExistsError(f"NFR '{name}' already exists")

        nfr = NonFunctionalRequirement(name=name, description=description)
        return self._repository.add(nfr)

    def delete_requirement(self, nfr_id: UUID) -> None:
        requirement = self._repository.get(nfr_id)
        if not requirement:
            raise NFRNotFoundError(f"NFR {nfr_id} not found")

        self._repository.delete(nfr_id)
