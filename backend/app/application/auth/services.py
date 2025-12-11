from __future__ import annotations

from datetime import datetime, timedelta
from uuid import uuid4

import bcrypt
from jose import JWTError, jwt

from app.core.config import get_settings
from app.domain.auth.entities import User
from app.domain.auth.exceptions import (
    InvalidCredentialsError,
    UserAlreadyExistsError,
)
from app.domain.auth.repositories import UserRepository


class AuthService:
    """Service for authentication and authorization."""

    def __init__(self, user_repository: UserRepository) -> None:
        self._user_repository = user_repository
        self._settings = get_settings()

    def hash_password(self, password: str) -> str:
        """Hash a password using bcrypt."""
        # Encode password to bytes, hash it, and decode back to string
        password_bytes = password.encode("utf-8")
        salt = bcrypt.gensalt(rounds=12)
        hashed = bcrypt.hashpw(password_bytes, salt)
        return hashed.decode("utf-8")

    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """Verify a password against its hash."""
        try:
            password_bytes = plain_password.encode("utf-8")
            hashed_bytes = hashed_password.encode("utf-8")
            return bcrypt.checkpw(password_bytes, hashed_bytes)
        except Exception:
            return False

    def create_access_token(self, user_id: str, email: str) -> str:
        """Create a JWT access token for a user."""
        expires_delta = timedelta(
            minutes=self._settings.jwt_access_token_expire_minutes
        )
        expire = datetime.utcnow() + expires_delta
        to_encode = {"sub": user_id, "email": email, "exp": expire}
        encoded_jwt = jwt.encode(
            to_encode,
            self._settings.jwt_secret_key,
            algorithm=self._settings.jwt_algorithm,
        )
        return encoded_jwt

    def verify_token(self, token: str) -> dict:
        """Verify and decode a JWT token."""
        try:
            payload = jwt.decode(
                token,
                self._settings.jwt_secret_key,
                algorithms=[self._settings.jwt_algorithm],
            )
            return payload
        except JWTError as exc:
            raise InvalidCredentialsError("Invalid token") from exc

    def register_user(self, email: str, password: str) -> User:
        """Register a new user."""
        # Check if user already exists
        existing_user = self._user_repository.get_by_email(email)
        if existing_user:
            raise UserAlreadyExistsError(f"User with email {email} already exists")

        # Create new user
        hashed_password = self.hash_password(password)
        user = User(email=email, hashed_password=hashed_password, id=uuid4())
        return self._user_repository.add(user)

    def authenticate_user(self, email: str, password: str) -> User:
        """Authenticate a user and return the user entity."""
        user = self._user_repository.get_by_email(email)
        if not user:
            raise InvalidCredentialsError("Invalid email or password")

        if not self.verify_password(password, user.hashed_password):
            raise InvalidCredentialsError("Invalid email or password")

        return user

    def login(self, email: str, password: str) -> tuple[User, str]:
        """Login a user and return user entity and access token."""
        user = self.authenticate_user(email, password)
        token = self.create_access_token(str(user.id), user.email)
        return user, token
