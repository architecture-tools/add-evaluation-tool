#!/usr/bin/env python3
"""Initialize database schema."""

import sys
from pathlib import Path

# Add parent directory to path to import app modules
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.infrastructure.persistence.database import init_db


if __name__ == "__main__":
    print("Initializing database schema...")
    init_db()
    print("Database schema initialized successfully!")

