from __future__ import annotations

from uuid import UUID

from pydantic import BaseModel

from app.domain.diagrams.entities import ImpactValue, DiagramNFRComponentImpact


class MatrixCellResponse(BaseModel):
    id: UUID
    diagram_id: UUID
    nfr_id: UUID
    component_id: UUID
    impact: ImpactValue

    @classmethod
    def from_domain(cls, entry: DiagramNFRComponentImpact) -> "MatrixCellResponse":
        return cls(
            id=entry.id,
            diagram_id=entry.diagram_id,
            nfr_id=entry.nfr_id,
            component_id=entry.component_id,
            impact=entry.impact,
        )


class NFRScoreResponse(BaseModel):
    nfr_id: UUID
    score: float


class DiagramMatrixResponse(BaseModel):
    entries: list[MatrixCellResponse]
    nfr_scores: list[NFRScoreResponse]
    overall_score: float | None = None


class UpdateMatrixCellRequest(BaseModel):
    nfr_id: UUID
    component_id: UUID
    impact: ImpactValue


class MatrixCellUpdateResponse(BaseModel):
    entry: MatrixCellResponse
    nfr_score: NFRScoreResponse
    overall_score: float | None = None
