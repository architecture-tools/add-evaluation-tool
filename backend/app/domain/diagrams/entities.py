from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import Dict, Optional
from uuid import UUID, uuid4


class DiagramStatus(str, Enum):
    UPLOADED = "uploaded"
    PARSED = "parsed"
    ANALYSIS_READY = "analysis_ready"
    FAILED = "failed"


@dataclass(slots=True)
class Diagram:
    name: str
    source_url: str
    content: str
    checksum: str
    status: DiagramStatus = DiagramStatus.UPLOADED
    id: UUID = field(default_factory=uuid4)
    uploaded_at: datetime = field(default_factory=datetime.utcnow)
    parsed_at: Optional[datetime] = None

    def mark_parsed(self) -> None:
        self.status = DiagramStatus.PARSED
        self.parsed_at = datetime.utcnow()

    def mark_failed(self) -> None:
        self.status = DiagramStatus.FAILED


class ComponentType(str, Enum):
    COMPONENT = "component"
    INTERFACE = "interface"
    ACTOR = "actor"
    PACKAGE = "package"
    DATABASE = "database"
    QUEUE = "queue"
    SYSTEM = "system"
    EXTERNAL = "external"


@dataclass(slots=True)
class Component:
    diagram_id: UUID
    name: str
    type: ComponentType
    metadata: Dict[str, str] = field(default_factory=dict)
    id: UUID = field(default_factory=uuid4)


class RelationshipDirection(str, Enum):
    UNIDIRECTIONAL = "unidirectional"
    BIDIRECTIONAL = "bidirectional"


@dataclass(slots=True)
class Relationship:
    diagram_id: UUID
    source_component_id: UUID
    target_component_id: UUID
    label: Optional[str] = None
    direction: RelationshipDirection = RelationshipDirection.UNIDIRECTIONAL
    metadata: Dict[str, str] = field(default_factory=dict)
    id: UUID = field(default_factory=uuid4)


class ImpactValue(str, Enum):
    POSITIVE = "POSITIVE"
    NO_EFFECT = "NO_EFFECT"
    NEGATIVE = "NEGATIVE"


@dataclass(slots=True)
class DiagramNFRComponentImpact:
    diagram_id: UUID
    nfr_id: UUID
    component_id: UUID
    impact: ImpactValue = ImpactValue.NO_EFFECT
    id: UUID = field(default_factory=uuid4)
