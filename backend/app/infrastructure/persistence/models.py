from __future__ import annotations

from datetime import datetime
from typing import Dict
from uuid import UUID

from sqlalchemy import JSON, String, Text, DateTime, ForeignKey, Enum, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


class DiagramModel(Base):
    __tablename__ = "diagrams"

    id: Mapped[UUID] = mapped_column(PGUUID(as_uuid=True), primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    source_url: Mapped[str] = mapped_column(Text, nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    checksum: Mapped[str] = mapped_column(
        String(64), nullable=False, unique=True, index=True
    )
    status: Mapped[str] = mapped_column(String(20), nullable=False)
    uploaded_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False
    )
    parsed_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    components: Mapped[list[ComponentModel]] = relationship(
        "ComponentModel", back_populates="diagram", cascade="all, delete-orphan"
    )
    relationships: Mapped[list[RelationshipModel]] = relationship(
        "RelationshipModel", back_populates="diagram", cascade="all, delete-orphan"
    )


class ComponentModel(Base):
    __tablename__ = "components"

    id: Mapped[UUID] = mapped_column(PGUUID(as_uuid=True), primary_key=True)
    diagram_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("diagrams.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    name: Mapped[str] = mapped_column(String(255), nullable=False)
    type: Mapped[str] = mapped_column(String(50), nullable=False)
    meta_data: Mapped[Dict[str, str]] = mapped_column(
        "metadata", JSON, nullable=False, default=dict
    )

    diagram: Mapped[DiagramModel] = relationship(
        "DiagramModel", back_populates="components"
    )


class RelationshipModel(Base):
    __tablename__ = "relationships"

    id: Mapped[UUID] = mapped_column(PGUUID(as_uuid=True), primary_key=True)
    diagram_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("diagrams.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    source_component_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True), nullable=False, index=True
    )
    target_component_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True), nullable=False, index=True
    )
    label: Mapped[str | None] = mapped_column(String(255), nullable=True)
    direction: Mapped[str] = mapped_column(String(20), nullable=False)
    meta_data: Mapped[Dict[str, str]] = mapped_column(
        "metadata", JSON, nullable=False, default=dict
    )

    diagram: Mapped[DiagramModel] = relationship(
        "DiagramModel", back_populates="relationships"
    )


class NonFunctionalRequirementModel(Base):
    __tablename__ = "non_functional_requirements"

    id: Mapped[UUID] = mapped_column(PGUUID(as_uuid=True), primary_key=True)
    name: Mapped[str] = mapped_column(String(255), nullable=False, unique=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=datetime.utcnow
    )


class DiagramImpactModel(Base):
    __tablename__ = "diagram_nfr_component_impacts"
    __table_args__ = (
        UniqueConstraint("diagram_id", "nfr_id", "component_id", name="uq_matrix_cell"),
    )

    id: Mapped[UUID] = mapped_column(PGUUID(as_uuid=True), primary_key=True)
    diagram_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("diagrams.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    nfr_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("non_functional_requirements.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    component_id: Mapped[UUID] = mapped_column(
        PGUUID(as_uuid=True),
        ForeignKey("components.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    impact: Mapped[str] = mapped_column(
        Enum("POSITIVE", "NO_EFFECT", "NEGATIVE", name="impact_value"),
        nullable=False,
        default="NO_EFFECT",
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=datetime.utcnow
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, default=datetime.utcnow
    )
