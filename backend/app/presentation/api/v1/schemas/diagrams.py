from __future__ import annotations

from datetime import datetime
from uuid import UUID

from typing import Literal

from pydantic import BaseModel

from app.domain.diagrams.entities import (
    Component,
    ComponentType,
    Diagram,
    DiagramStatus,
    Relationship,
    RelationshipDirection,
)


class DiagramResponse(BaseModel):
    id: UUID
    name: str
    status: DiagramStatus
    source_url: str
    uploaded_at: datetime
    parsed_at: datetime | None = None

    @classmethod
    def from_domain(cls, diagram: Diagram) -> "DiagramResponse":
        return cls(
            id=diagram.id,
            name=diagram.name,
            status=diagram.status,
            source_url=diagram.source_url,
            uploaded_at=diagram.uploaded_at,
            parsed_at=diagram.parsed_at,
        )

    class Config:
        json_encoders = {
            UUID: str,
        }


class ComponentResponse(BaseModel):
    id: UUID
    name: str
    type: ComponentType

    @classmethod
    def from_domain(cls, component: Component) -> "ComponentResponse":
        return cls(
            id=component.id,
            name=component.name,
            type=component.type,
        )

    class Config:
        json_encoders = {
            UUID: str,
        }


class RelationshipResponse(BaseModel):
    id: UUID
    source_component_id: UUID
    target_component_id: UUID
    label: str | None = None
    direction: RelationshipDirection

    @classmethod
    def from_domain(cls, relationship: Relationship) -> "RelationshipResponse":
        return cls(
            id=relationship.id,
            source_component_id=relationship.source_component_id,
            target_component_id=relationship.target_component_id,
            label=relationship.label,
            direction=relationship.direction,
        )

    class Config:
        json_encoders = {
            UUID: str,
        }


class ParseDiagramResponse(BaseModel):
    diagram: DiagramResponse
    components: list[ComponentResponse]
    relationships: list[RelationshipResponse]


class ComponentDiffResponse(BaseModel):
    name: str
    change_type: Literal["added", "removed", "modified"]
    previous_type: ComponentType | None = None
    new_type: ComponentType | None = None


class RelationshipDiffResponse(BaseModel):
    source: str
    target: str
    change_type: Literal["added", "removed", "modified"]
    previous_label: str | None = None
    new_label: str | None = None
    previous_direction: RelationshipDirection | None = None
    new_direction: RelationshipDirection | None = None


class DiagramDiffResponse(BaseModel):
    base_diagram_id: UUID
    target_diagram_id: UUID
    components: list[ComponentDiffResponse]
    relationships: list[RelationshipDiffResponse]
