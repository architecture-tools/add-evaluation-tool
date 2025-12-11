from __future__ import annotations

from uuid import UUID, uuid4

import pytest

from app.application.nfr.services import NFRService
from app.domain.nfr.entities import NonFunctionalRequirement
from app.domain.nfr.exceptions import NFRAlreadyExistsError, NFRNotFoundError
from app.domain.nfr.repositories import NonFunctionalRequirementRepository


class InMemoryNFRRepository(NonFunctionalRequirementRepository):
    def __init__(self) -> None:
        self._items: dict[UUID, NonFunctionalRequirement] = {}

    def add(self, nfr: NonFunctionalRequirement) -> NonFunctionalRequirement:
        self._items[nfr.id] = nfr
        return nfr

    def get(self, nfr_id: UUID) -> NonFunctionalRequirement | None:
        return self._items.get(nfr_id)

    def get_by_name(self, name: str) -> NonFunctionalRequirement | None:
        return next((item for item in self._items.values() if item.name == name), None)

    def list(self):
        return list(self._items.values())

    def delete(self, nfr_id: UUID) -> None:
        self._items.pop(nfr_id, None)


@pytest.fixture()
def service() -> NFRService:
    return NFRService(repository=InMemoryNFRRepository())


def test_create_requirement_persists_and_returns_entity(service: NFRService) -> None:
    nfr = service.create_requirement("Security", "Ensure encryption everywhere")

    assert nfr.name == "Security"
    assert nfr.description == "Ensure encryption everywhere"
    assert nfr.id in [item.id for item in service.list_requirements()]


def test_create_requirement_prevents_duplicate_names(service: NFRService) -> None:
    service.create_requirement("Performance")

    with pytest.raises(NFRAlreadyExistsError):
        service.create_requirement("Performance")


def test_delete_requirement_removes_entity(service: NFRService) -> None:
    nfr = service.create_requirement("Reliability")
    assert len(service.list_requirements()) == 1

    service.delete_requirement(nfr.id)
    assert len(service.list_requirements()) == 0


def test_delete_missing_requirement_raises_error(service: NFRService) -> None:
    with pytest.raises(NFRNotFoundError):
        service.delete_requirement(uuid4())
