class DiagramError(Exception):
    """Base class for diagram domain exceptions."""


class DiagramAlreadyExistsError(DiagramError):
    """Raised when attempting to create a diagram with duplicate checksum."""


class DiagramNotFoundError(DiagramError):
    """Raised when a diagram cannot be located."""


class ParseError(DiagramError):
    """Raised when PlantUML content cannot be parsed."""
