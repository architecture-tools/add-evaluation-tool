from fastapi import APIRouter, Depends, HTTPException, status
from uuid import UUID

from app.application.auth.services import AuthService
from app.domain.auth.exceptions import (
    InvalidCredentialsError,
    UserAlreadyExistsError,
)
from app.presentation.api.dependencies import get_auth_service, get_current_user
from app.presentation.api.v1.schemas.auth import (
    LoginResponse,
    RegisterResponse,
    TokenResponse,
    UserLoginRequest,
    UserRegisterRequest,
    UserResponse,
)

router = APIRouter()


@router.post(
    "/auth/register",
    response_model=RegisterResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Register a new user",
)
async def register(
    request: UserRegisterRequest,
    auth_service: AuthService = Depends(get_auth_service),
) -> RegisterResponse:
    try:
        user = auth_service.register_user(request.email, request.password)
        token = auth_service.create_access_token(str(user.id), user.email)
        return RegisterResponse(
            user=UserResponse.from_domain(user),
            token=TokenResponse(access_token=token, token_type="bearer"),
        )
    except UserAlreadyExistsError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail={
                "code": "user/already-exists",
                "message": str(exc),
            },
        ) from exc


@router.post(
    "/auth/login",
    response_model=LoginResponse,
    summary="Login user",
)
async def login(
    request: UserLoginRequest,
    auth_service: AuthService = Depends(get_auth_service),
) -> LoginResponse:
    try:
        user, token = auth_service.login(request.email, request.password)
        return LoginResponse(
            user=UserResponse.from_domain(user),
            token=TokenResponse(access_token=token, token_type="bearer"),
        )
    except InvalidCredentialsError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={
                "code": "auth/invalid-credentials",
                "message": str(exc),
            },
        ) from exc


@router.get(
    "/auth/me",
    response_model=UserResponse,
    summary="Get current user",
)
async def get_me(
    current_user: dict = Depends(get_current_user),
) -> UserResponse:
    return UserResponse(
        id=UUID(current_user["sub"]),
        email=current_user["email"],
    )
