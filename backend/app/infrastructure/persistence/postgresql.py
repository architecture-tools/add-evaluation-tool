from __future__ import annotations

from datetime import datetime
from typing import Iterable, Optional, Sequence
from uuid import UUID

from sqlalchemy.orm import Session

from app.domain.diagrams.entities import (
    Component,
    Diagram,
    DiagramNFRComponentImpact,
    DiagramStatus,
    ImpactValue,
    ComponentType,
    Relationship,
    RelationshipDirection,
)
from app.domain.diagrams.repositories import DiagramRepository
from app.domain.diagrams.matrix_repository import DiagramMatrixRepository
from app.domain.nfr.entities import NonFunctionalRequirement
from app.domain.nfr.repositories import NonFunctionalRequirementRepository
from app.domain.auth.entities import User as UserEntity
from app.domain.auth.repositories import UserRepository
from app.infrastructure.persistence.models import (
    DiagramModel,
    ComponentModel,
    RelationshipModel,
    NonFunctionalRequirementModel,
    DiagramImpactModel,
    UserModel,
)


class PostgreSQLDiagramRepository(DiagramRepository):
    """PostgreSQL implementation of DiagramRepository."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def add(self, diagram: Diagram) -> Diagram:
        """Persist a new diagram aggregate."""
        try:
            diagram_model = DiagramModel(
                id=diagram.id,
                user_id=diagram.user_id,
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
            diagram_model = (
                self._session.query(DiagramModel)
                .filter(DiagramModel.id == diagram.id)
                .first()
            )
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
        diagram_model = (
            self._session.query(DiagramModel)
            .filter(DiagramModel.id == diagram_id)
            .first()
        )
        if diagram_model is None:
            return None
        return self._to_domain_entity(diagram_model)

    def list(self, user_id: UUID) -> Iterable[Diagram]:
        """Return all diagrams for a user."""
        diagram_models = (
            self._session.query(DiagramModel)
            .filter(DiagramModel.user_id == user_id)
            .all()
        )
        return [self._to_domain_entity(model) for model in diagram_models]

    def find_by_checksum(self, user_id: UUID, checksum: str) -> Optional[Diagram]:
        """Retrieve a diagram by user_id and checksum to prevent duplicates."""
        diagram_model = (
            self._session.query(DiagramModel)
            .filter(
                DiagramModel.user_id == user_id,
                DiagramModel.checksum == checksum,
            )
            .first()
        )
        if diagram_model is None:
            return None
        return self._to_domain_entity(diagram_model)

    def add_components(self, components: Sequence[Component]) -> None:
        """Persist components for a diagram."""
        if not components:
            return
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

    def update_components(self, components: Sequence[Component]) -> None:
        """Update existing components for a diagram."""
        if not components:
            return
        try:
            for component in components:
                component_model = (
                    self._session.query(ComponentModel)
                    .filter(ComponentModel.id == component.id)
                    .first()
                )
                if component_model is None:
                    continue
                component_model.name = component.name
                component_model.type = component.type.value
                component_model.meta_data = component.metadata
            self._session.commit()
        except Exception:
            self._session.rollback()
            raise

    def delete_components(
        self, diagram_id: UUID, component_ids: Iterable[UUID] | None = None
    ) -> None:
        """Delete components for a diagram."""
        try:
            query = self._session.query(ComponentModel).filter(
                ComponentModel.diagram_id == diagram_id
            )
            if component_ids is not None:
                ids = list(component_ids)
                if not ids:
                    return
                query = query.filter(ComponentModel.id.in_(ids))
            query.delete(synchronize_session=False)
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

    def delete_relationships(self, diagram_id: UUID) -> None:
        """Delete all relationships for a diagram."""
        try:
            (
                self._session.query(RelationshipModel)
                .filter(RelationshipModel.diagram_id == diagram_id)
                .delete(synchronize_session=False)
            )
            self._session.commit()
        except Exception:
            self._session.rollback()
            raise

    def _to_domain_entity(self, model: DiagramModel) -> Diagram:
        """Convert database model to domain entity."""
        return Diagram(
            id=model.id,
            user_id=model.user_id,
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


class PostgreSQLNFRRepository(NonFunctionalRequirementRepository):
    """PostgreSQL implementation for managing NFRs."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def add(self, nfr: NonFunctionalRequirement) -> NonFunctionalRequirement:
        try:
            model = NonFunctionalRequirementModel(
                id=nfr.id,
                name=nfr.name,
                description=nfr.description,
                created_at=nfr.created_at,
            )
            self._session.add(model)
            self._session.commit()
            self._session.refresh(model)
            return nfr
        except Exception:
            self._session.rollback()
            raise

    def get(self, nfr_id: UUID) -> Optional[NonFunctionalRequirement]:
        model = (
            self._session.query(NonFunctionalRequirementModel)
            .filter(NonFunctionalRequirementModel.id == nfr_id)
            .first()
        )
        if model is None:
            return None
        return self._to_domain_entity(model)

    def get_by_name(self, name: str) -> Optional[NonFunctionalRequirement]:
        model = (
            self._session.query(NonFunctionalRequirementModel)
            .filter(NonFunctionalRequirementModel.name == name)
            .first()
        )
        if model is None:
            return None
        return self._to_domain_entity(model)

    def list(self) -> Iterable[NonFunctionalRequirement]:
        models = self._session.query(NonFunctionalRequirementModel).order_by(
            NonFunctionalRequirementModel.name.asc()
        )
        return [self._to_domain_entity(model) for model in models]

    def delete(self, nfr_id: UUID) -> None:
        try:
            (
                self._session.query(NonFunctionalRequirementModel)
                .filter(NonFunctionalRequirementModel.id == nfr_id)
                .delete(synchronize_session=False)
            )
            self._session.commit()
        except Exception:
            self._session.rollback()
            raise

    def _to_domain_entity(
        self, model: NonFunctionalRequirementModel
    ) -> NonFunctionalRequirement:
        return NonFunctionalRequirement(
            id=model.id,
            name=model.name,
            description=model.description,
            created_at=model.created_at,
        )


class PostgreSQLDiagramMatrixRepository(DiagramMatrixRepository):
    """PostgreSQL implementation for diagram matrix storage."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def list_by_diagram(self, diagram_id: UUID) -> Sequence[DiagramNFRComponentImpact]:
        models = (
            self._session.query(DiagramImpactModel)
            .filter(DiagramImpactModel.diagram_id == diagram_id)
            .all()
        )
        return [self._to_domain_entity(model) for model in models]

    def upsert(
        self,
        diagram_id: UUID,
        nfr_id: UUID,
        component_id: UUID,
        impact: ImpactValue,
    ) -> DiagramNFRComponentImpact:
        try:
            model = (
                self._session.query(DiagramImpactModel)
                .filter(
                    DiagramImpactModel.diagram_id == diagram_id,
                    DiagramImpactModel.nfr_id == nfr_id,
                    DiagramImpactModel.component_id == component_id,
                )
                .one_or_none()
            )
            if model is None:
                model = DiagramImpactModel(
                    diagram_id=diagram_id,
                    nfr_id=nfr_id,
                    component_id=component_id,
                    impact=impact.value,
                )
                self._session.add(model)
            else:
                model.impact = impact.value
                model.updated_at = datetime.utcnow()
            self._session.commit()
            self._session.refresh(model)
            return self._to_domain_entity(model)
        except Exception:
            self._session.rollback()
            raise

    def ensure_pairs(
        self,
        diagram_id: UUID,
        pairs: Iterable[tuple[UUID, UUID]],
        default_impact: ImpactValue = ImpactValue.NO_EFFECT,
    ) -> None:
        try:
            pairs_set = set(pairs)
            if not pairs_set:
                return

            existing = (
                self._session.query(
                    DiagramImpactModel.nfr_id, DiagramImpactModel.component_id
                )
                .filter(DiagramImpactModel.diagram_id == diagram_id)
                .all()
            )
            existing_set = {(row[0], row[1]) for row in existing}
            missing = pairs_set - existing_set

            if missing:
                entries = [
                    DiagramImpactModel(
                        diagram_id=diagram_id,
                        nfr_id=nfr_id,
                        component_id=component_id,
                        impact=default_impact.value,
                    )
                    for nfr_id, component_id in missing
                ]
                self._session.add_all(entries)
            self._session.commit()
        except Exception:
            self._session.rollback()
            raise

    def delete_missing_components(
        self, diagram_id: UUID, component_ids: Iterable[UUID]
    ) -> None:
        try:
            component_ids_set = set(component_ids)
            query = self._session.query(DiagramImpactModel).filter(
                DiagramImpactModel.diagram_id == diagram_id
            )
            if component_ids_set:
                query = query.filter(
                    ~DiagramImpactModel.component_id.in_(component_ids_set)
                )
            # If there are no components, remove all entries for the diagram
            query.delete(synchronize_session=False)
            self._session.commit()
        except Exception:
            self._session.rollback()
            raise

    def _to_domain_entity(self, model: DiagramImpactModel) -> DiagramNFRComponentImpact:
        return DiagramNFRComponentImpact(
            id=model.id,
            diagram_id=model.diagram_id,
            nfr_id=model.nfr_id,
            component_id=model.component_id,
            impact=ImpactValue(model.impact),
        )


class PostgreSQLUserRepository(UserRepository):
    """PostgreSQL implementation of UserRepository."""

    def __init__(self, session: Session) -> None:
        self._session = session

    def add(self, user: UserEntity) -> UserEntity:
        """Persist a new user."""
        try:
            user_model = UserModel(
                id=user.id,
                email=user.email,
                hashed_password=user.hashed_password,
                created_at=user.created_at,
            )
            self._session.add(user_model)
            self._session.commit()
            self._session.refresh(user_model)
            return user
        except Exception:
            self._session.rollback()
            raise

    def get(self, user_id: UUID) -> Optional[UserEntity]:
        """Retrieve a user by its identifier."""
        user_model = (
            self._session.query(UserModel).filter(UserModel.id == user_id).first()
        )
        if user_model is None:
            return None
        return self._to_domain_entity(user_model)

    def get_by_email(self, email: str) -> Optional[UserEntity]:
        """Retrieve a user by email."""
        user_model = (
            self._session.query(UserModel).filter(UserModel.email == email).first()
        )
        if user_model is None:
            return None
        return self._to_domain_entity(user_model)

    def _to_domain_entity(self, model: UserModel) -> UserEntity:
        """Convert database model to domain entity."""
        return UserEntity(
            id=model.id,
            email=model.email,
            hashed_password=model.hashed_password,
            created_at=model.created_at,
        )
