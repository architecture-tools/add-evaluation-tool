from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from uuid import UUID

from app.application.diagrams.services import DiagramService
from app.domain.diagrams.exceptions import DiagramAlreadyExistsError, DiagramNotFoundError, ParseError
from app.presentation.api.dependencies import get_diagram_service
from app.presentation.api.v1.schemas import (
    ComponentResponse,
    DiagramResponse,
    ParseDiagramResponse,
    RelationshipResponse,
)

router = APIRouter()


@router.post(
    "/diagrams",
    response_model=DiagramResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Upload PlantUML diagram",
)
async def upload_diagram(
    file: UploadFile = File(...),
    name: str | None = Form(default=None),
    service: DiagramService = Depends(get_diagram_service),
) -> DiagramResponse:
    payload = await file.read()
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"code": "diagram/empty-file", "message": "Uploaded file is empty"},
        )

    try:
        diagram = service.upload_diagram(
            file.filename or "diagram.puml", payload, display_name=name
        )
    except DiagramAlreadyExistsError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail={
                "code": "diagram/already-exists",
                "message": "Diagram with identical content already exists",
                "diagramId": str(exc.args[0]),
            },
        ) from exc

    return DiagramResponse.from_domain(diagram)


@router.get(
    "/diagrams",
    response_model=list[DiagramResponse],
    summary="List all diagrams",
)
async def list_diagrams(
    service: DiagramService = Depends(get_diagram_service),
) -> list[DiagramResponse]:
    diagrams = service.list_diagrams()
    return [DiagramResponse.from_domain(diagram) for diagram in diagrams]


@router.get(
    "/diagrams/{diagram_id}",
    response_model=DiagramResponse,
    summary="Get diagram by ID",
)
async def get_diagram(
    diagram_id: UUID,
    service: DiagramService = Depends(get_diagram_service),
) -> DiagramResponse:
    diagram = service.get_diagram(diagram_id)
    if not diagram:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code": "diagram/not-found",
                "message": f"Diagram with ID {diagram_id} not found",
            },
        )
    return DiagramResponse.from_domain(diagram)


@router.post(
    "/diagrams/{diagram_id}/parse",
    response_model=ParseDiagramResponse,
    summary="Parse diagram to extract components and relationships",
)
async def parse_diagram(
    diagram_id: UUID,
    service: DiagramService = Depends(get_diagram_service),
) -> ParseDiagramResponse:
    try:
        components, relationships = service.parse_diagram(diagram_id)
    except DiagramNotFoundError as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code": "diagram/not-found",
                "message": str(exc),
            },
        ) from exc
    except ParseError as exc:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail={
                "code": "diagram/parse-error",
                "message": str(exc),
            },
        ) from exc

    diagram = service.get_diagram(diagram_id)
    if not diagram:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "code": "diagram/not-found",
                "message": f"Diagram with ID {diagram_id} not found",
            },
        )

    return ParseDiagramResponse(
        diagram=DiagramResponse.from_domain(diagram),
        components=[ComponentResponse.from_domain(c) for c in components],
        relationships=[RelationshipResponse.from_domain(r) for r in relationships],
    )
