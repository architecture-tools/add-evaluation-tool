class NFRAlreadyExistsError(ValueError):
    """Raised when creating a duplicate non-functional requirement."""


class NFRNotFoundError(LookupError):
    """Raised when requested non-functional requirement does not exist."""
