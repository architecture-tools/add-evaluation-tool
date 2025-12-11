from __future__ import annotations

from abc import ABC, abstractmethod
from typing import Optional
from uuid import UUID

from .entities import User


class UserRepository(ABC):
    """Repository abstraction for the User aggregate."""

    @abstractmethod
    def add(self, user: User) -> User:
        """Persist a new user."""

    @abstractmethod
    def get(self, user_id: UUID) -> Optional[User]:
        """Retrieve a user by its identifier."""

    @abstractmethod
    def get_by_email(self, email: str) -> Optional[User]:
        """Retrieve a user by email."""
