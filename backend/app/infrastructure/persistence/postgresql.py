from __future__ import annotations

from typing import Iterable, Optional, Sequence
from uuid import UUID

from sqlalchemy.orm import Session

from app.domain.diagrams.entities import Component, Diagram, Relationship, DiagramStatus, ComponentType, RelationshipDirection
from app.domain.diagrams.repositories import DiagramRepository
from app.infrastructure.persistence.models import DiagramModel, ComponentModel, RelationshipModel


class PostgreSQLDiagramRepository(DiagramRepository):
    """PostgreSQL implementation of DiagramRepository."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def add(self, diagram: Diagram) -> Diagram:
        """Persist a new diagram aggregate."""
        try:
            diagram_model = DiagramModel(
                id=diagram.id,
                name=diagram.name,
                source_url=diagram.source_url,
                content=diagram.content,
                checksum=diagram.checksum,
                status=diagram.status.value,
                uploaded_at=diagram.uploaded_at,
                parsed_at=diagram.parsed_at,
            )
            self._session.add(diagram_model)
            self._session.commit()
            self._session.refresh(diagram_model)
            return diagram
        except Exception:
            self._session.rollback()
            raise

    def update(self, diagram: Diagram) -> Diagram:
        """Update an existing diagram aggregate."""
        try:
            diagram_model = self._session.query(DiagramModel).filter(DiagramModel.id == diagram.id).first()
            if diagram_model is None:
                raise ValueError(f"Diagram {diagram.id} does not exist")
            
            diagram_model.name = diagram.name
            diagram_model.source_url = diagram.source_url
            diagram_model.content = diagram.content
            diagram_model.checksum = diagram.checksum
            diagram_model.status = diagram.status.value
            diagram_model.uploaded_at = diagram.uploaded_at
            diagram_model.parsed_at = diagram.parsed_at
            
            self._session.commit()
            self._session.refresh(diagram_model)
            return diagram
        except Exception:
            self._session.rollback()
            raise

    def get(self, diagram_id: UUID) -> Optional[Diagram]:
        """Retrieve a diagram by its identifier."""
        diagram_model = self._session.query(DiagramModel).filter(DiagramModel.id == diagram_id).first()
        if diagram_model is None:
            return None
        return self._to_domain_entity(diagram_model)

    def list(self) -> Iterable[Diagram]:
        """Return all diagrams."""
        diagram_models = self._session.query(DiagramModel).all()
        return [self._to_domain_entity(model) for model in diagram_models]

    def find_by_checksum(self, checksum: str) -> Optional[Diagram]:
        """Retrieve a diagram by checksum to prevent duplicates."""
        diagram_model = (
            self._session.query(DiagramModel).filter(DiagramModel.checksum == checksum).first()
        )
        if diagram_model is None:
            return None
        return self._to_domain_entity(diagram_model)

    def add_components(self, components: Sequence[Component]) -> None:
        """Persist components for a diagram."""
        try:
            component_models = [
                ComponentModel(
                    id=component.id,
                    diagram_id=component.diagram_id,
                    name=component.name,
                    type=component.type.value,
                    meta_data=component.metadata,
                )
                for component in components
            ]
            self._session.add_all(component_models)
            self._session.commit()
        except Exception:
            self._session.rollback()
            raise

    def add_relationships(self, relationships: Sequence[Relationship]) -> None:
        """Persist relationships for a diagram."""
        try:
            relationship_models = [
                RelationshipModel(
                    id=relationship.id,
                    diagram_id=relationship.diagram_id,
                    source_component_id=relationship.source_component_id,
                    target_component_id=relationship.target_component_id,
                    label=relationship.label,
                    direction=relationship.direction.value,
                    meta_data=relationship.metadata,
                )
                for relationship in relationships
            ]
            self._session.add_all(relationship_models)
            self._session.commit()
        except Exception:
            self._session.rollback()
            raise

    def get_components(self, diagram_id: UUID) -> Sequence[Component]:
        """Retrieve all components for a diagram."""
        component_models = (
            self._session.query(ComponentModel)
            .filter(ComponentModel.diagram_id == diagram_id)
            .all()
        )
        return [self._to_component_entity(model) for model in component_models]

    def get_relationships(self, diagram_id: UUID) -> Sequence[Relationship]:
        """Retrieve all relationships for a diagram."""
        relationship_models = (
            self._session.query(RelationshipModel)
            .filter(RelationshipModel.diagram_id == diagram_id)
            .all()
        )
        return [self._to_relationship_entity(model) for model in relationship_models]

    def _to_domain_entity(self, model: DiagramModel) -> Diagram:
        """Convert database model to domain entity."""
        return Diagram(
            id=model.id,
            name=model.name,
            source_url=model.source_url,
            content=model.content,
            checksum=model.checksum,
            status=DiagramStatus(model.status),
            uploaded_at=model.uploaded_at,
            parsed_at=model.parsed_at,
        )

    def _to_component_entity(self, model: ComponentModel) -> Component:
        """Convert database model to component entity."""
        return Component(
            id=model.id,
            diagram_id=model.diagram_id,
            name=model.name,
            type=ComponentType(model.type),
            metadata=model.meta_data,
        )

    def _to_relationship_entity(self, model: RelationshipModel) -> Relationship:
        """Convert database model to relationship entity."""
        return Relationship(
            id=model.id,
            diagram_id=model.diagram_id,
            source_component_id=model.source_component_id,
            target_component_id=model.target_component_id,
            label=model.label,
            direction=RelationshipDirection(model.direction),
            metadata=model.meta_data,
        )

