from __future__ import annotations

import pytest

from uuid import uuid4

from app.domain.diagrams.entities import Component, ComponentType, Diagram, Relationship
from app.infrastructure.persistence.in_memory import InMemoryDiagramRepository


def test_add_and_get_returns_same_diagram() -> None:
    # Arrange
    repository = InMemoryDiagramRepository()
    user_id = uuid4()
    diagram = Diagram(
        user_id=user_id,
        name="Pricing",
        source_url="diagram://pricing",
        content="[]",
        checksum="pricing-123",
    )

    # Act
    repository.add(diagram)
    retrieved = repository.get(diagram.id)

    # Assert
    assert retrieved is diagram
    assert list(repository.list(user_id)) == [diagram]


def test_update_missing_diagram_raises_value_error() -> None:
    # Arrange
    repository = InMemoryDiagramRepository()
    user_id = uuid4()
    orphan_diagram = Diagram(
        user_id=user_id,
        name="Orphan",
        source_url="diagram://orphan",
        content="[]",
        checksum="orphan-123",
    )

    # Act
    with pytest.raises(ValueError) as excinfo:
        repository.update(orphan_diagram)

    # Assert
    assert "does not exist" in str(excinfo.value)


def test_checksum_lookup_and_component_relationship_grouping() -> None:
    # Arrange
    repository = InMemoryDiagramRepository()
    user_id = uuid4()
    diagram = Diagram(
        user_id=user_id,
        name="Fulfillment",
        source_url="diagram://fulfillment",
        content="[]",
        checksum="fulfillment-123",
    )
    repository.add(diagram)
    components = [
        Component(diagram_id=diagram.id, name="API", type=ComponentType.COMPONENT),
        Component(diagram_id=diagram.id, name="DB", type=ComponentType.DATABASE),
    ]
    relationships = [
        Relationship(
            diagram_id=diagram.id,
            source_component_id=components[0].id,
            target_component_id=components[1].id,
        )
    ]

    # Act
    repository.add_components(components)
    repository.add_relationships(relationships)
    checksum_match = repository.find_by_checksum(user_id, diagram.checksum)

    # Assert
    assert checksum_match is diagram
    assert repository.get_components(diagram.id) == components
    assert repository.get_relationships(diagram.id) == relationships


def test_update_and_delete_components_and_relationships() -> None:
    repository = InMemoryDiagramRepository()
    user_id = uuid4()
    diagram = Diagram(
        user_id=user_id,
        name="Lifecycle",
        source_url="diagram://lifecycle",
        content="[]",
        checksum="lifecycle-123",
    )
    repository.add(diagram)

    api = Component(diagram_id=diagram.id, name="API", type=ComponentType.COMPONENT)
    db = Component(diagram_id=diagram.id, name="DB", type=ComponentType.DATABASE)

    repository.add_components([api, db])

    updated_api = Component(
        diagram_id=diagram.id, name="API v2", type=ComponentType.COMPONENT, id=api.id
    )

    repository.update_components([updated_api])

    stored_components = repository.get_components(diagram.id)
    assert stored_components[0].name == "API v2"

    repository.delete_components(diagram.id, [db.id])
    remaining_components = repository.get_components(diagram.id)
    assert remaining_components == [db]

    repository.delete_components(diagram.id)
    assert repository.get_components(diagram.id) == []

    relationship = Relationship(
        diagram_id=diagram.id,
        source_component_id=api.id,
        target_component_id=db.id,
    )
    repository.add_relationships([relationship])
    assert repository.get_relationships(diagram.id) == [relationship]

    repository.delete_relationships(diagram.id)
    assert repository.get_relationships(diagram.id) == []
