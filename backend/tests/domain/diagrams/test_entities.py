from __future__ import annotations

from uuid import uuid4

from app.domain.diagrams.entities import (
    Component,
    ComponentType,
    Diagram,
    DiagramStatus,
    Relationship,
    RelationshipDirection,
)


def test_diagram_mark_parsed_updates_status_and_timestamp() -> None:
    # Arrange
    user_id = uuid4()
    diagram = Diagram(
        user_id=user_id,
        name="Payments Flow",
        source_url="diagram://payments",
        content="[]",
        checksum="abc123",
    )
    original_uploaded_at = diagram.uploaded_at

    # Act
    diagram.mark_parsed()

    # Assert
    assert diagram.status == DiagramStatus.PARSED
    assert diagram.parsed_at is not None
    assert diagram.parsed_at >= original_uploaded_at


def test_diagram_mark_failed_sets_failed_status_without_timestamp() -> None:
    # Arrange
    user_id = uuid4()
    diagram = Diagram(
        user_id=user_id,
        name="Checkout",
        source_url="diagram://checkout",
        content="[]",
        checksum="def456",
    )

    # Act
    diagram.mark_failed()

    # Assert
    assert diagram.status == DiagramStatus.FAILED
    assert diagram.parsed_at is None


def test_component_and_relationship_metadata_are_not_shared() -> None:
    # Arrange
    user_id = uuid4()
    diagram = Diagram(
        user_id=user_id,
        name="Inventory",
        source_url="diagram://inventory",
        content="[]",
        checksum="ghi789",
    )
    component_a = Component(
        diagram_id=diagram.id, name="API", type=ComponentType.COMPONENT
    )
    component_b = Component(
        diagram_id=diagram.id, name="DB", type=ComponentType.DATABASE
    )
    relationship = Relationship(
        diagram_id=diagram.id,
        source_component_id=component_a.id,
        target_component_id=component_b.id,
        direction=RelationshipDirection.BIDIRECTIONAL,
    )

    # Act
    component_a.metadata["tier"] = "stateless"
    relationship.metadata["critical"] = "yes"

    # Assert
    assert component_b.metadata == {}
    assert component_a.metadata["tier"] == "stateless"
    assert relationship.metadata["critical"] == "yes"
