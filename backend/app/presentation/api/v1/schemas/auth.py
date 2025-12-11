from __future__ import annotations

from pydantic import BaseModel, EmailStr, Field
from uuid import UUID


class UserRegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(
        ..., min_length=8, description="Password must be at least 8 characters"
    )


class UserLoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserResponse(BaseModel):
    id: UUID
    email: str

    @classmethod
    def from_domain(cls, user) -> "UserResponse":
        return cls(id=user.id, email=user.email)


class RegisterResponse(BaseModel):
    user: UserResponse
    token: TokenResponse


class LoginResponse(BaseModel):
    user: UserResponse
    token: TokenResponse
