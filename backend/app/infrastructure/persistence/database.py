from __future__ import annotations

from collections.abc import Generator

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session

from app.core.config import get_settings
from app.infrastructure.persistence.models import Base


def get_database_url() -> str:
    """Get database URL from settings."""
    return get_settings().database_url


def create_engine_instance():
    """Create SQLAlchemy engine."""
    return create_engine(
        get_database_url(),
        pool_pre_ping=True,
        echo=False,
    )


engine = create_engine_instance()
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def init_db() -> None:
    """Initialize database tables."""
    Base.metadata.create_all(bind=engine)


def get_db() -> Generator[Session, None, None]:
    """Dependency for getting database session."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
