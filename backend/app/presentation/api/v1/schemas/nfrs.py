from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from app.domain.nfr.entities import NonFunctionalRequirement


class CreateNFRRequest(BaseModel):
    name: str = Field(..., max_length=255, description="Short name of the NFR")
    description: str | None = Field(
        default=None, description="Optional description for the NFR"
    )


class NFRResponse(BaseModel):
    id: UUID
    name: str
    description: str | None = None
    created_at: datetime

    @classmethod
    def from_domain(cls, nfr: NonFunctionalRequirement) -> "NFRResponse":
        return cls(
            id=nfr.id,
            name=nfr.name,
            description=nfr.description,
            created_at=nfr.created_at,
        )

    class Config:
        json_encoders = {
            UUID: str,
        }
