from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status

from app.application.nfr.services import NFRService
from app.domain.nfr.exceptions import NFRAlreadyExistsError, NFRNotFoundError
from app.presentation.api.dependencies import get_nfr_service
from app.presentation.api.v1.schemas import CreateNFRRequest, NFRResponse

router = APIRouter(prefix="/nfrs")


@router.get(
    "",
    response_model=list[NFRResponse],
    summary="List all non-functional requirements",
)
async def list_nfrs(
    service: NFRService = Depends(get_nfr_service),
) -> list[NFRResponse]:
    requirements = service.list_requirements()
    return [NFRResponse.from_domain(nfr) for nfr in requirements]


@router.post(
    "",
    response_model=NFRResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new non-functional requirement",
)
async def create_nfr(
    payload: CreateNFRRequest, service: NFRService = Depends(get_nfr_service)
) -> NFRResponse:
    try:
        nfr = service.create_requirement(payload.name, payload.description)
    except NFRAlreadyExistsError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail={
                "code": "nfr/already-exists",
                "message": str(exc),
            },
        ) from exc

    return NFRResponse.from_domain(nfr)


@router.delete(
    "/{nfr_id}",
    status_code=status.HTTP_200_OK,
    summary="Delete an existing non-functional requirement",
)
async def delete_nfr(
    nfr_id: UUID, service: NFRService = Depends(get_nfr_service)
) -> dict[str, str]:
    try:
        service.delete_requirement(nfr_id)
    except NFRNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code": "nfr/not-found",
                "message": str(exc),
            },
        ) from exc
    return {"status": "deleted"}
