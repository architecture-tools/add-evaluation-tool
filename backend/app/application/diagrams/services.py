from __future__ import annotations

import time
from dataclasses import dataclass
from hashlib import sha256
from typing import Any, Dict, Iterable, Literal, Optional, Sequence
from uuid import UUID, uuid5

from opentelemetry import metrics, trace
from opentelemetry.metrics import Counter, Histogram

from app.domain.diagrams.entities import (
    Component,
    ComponentType,
    Diagram,
    Relationship,
    RelationshipDirection,
)
from app.domain.diagrams.exceptions import (
    DiagramAlreadyExistsError,
    DiagramNotFoundError,
    ParseError,
)
from app.domain.diagrams.parsers import PlantUMLParser
from app.domain.diagrams.repositories import DiagramRepository

from .ports import DiagramStorage


@dataclass(slots=True)
class ComponentDiff:
    name: str
    change_type: Literal["added", "removed", "modified"]
    previous_type: ComponentType | None = None
    new_type: ComponentType | None = None


@dataclass(slots=True)
class RelationshipDiff:
    source: str
    target: str
    change_type: Literal["added", "removed", "modified"]
    previous_label: str | None = None
    new_label: str | None = None
    previous_direction: RelationshipDirection | None = None
    new_direction: RelationshipDirection | None = None


class DiagramService:
    _parsing_duration: Optional[Histogram] = None
    _diagram_uploaded_counter: Optional[Counter] = None
    _parsing_succeeded_counter: Optional[Counter] = None
    _parsing_failed_counter: Optional[Counter] = None
    _evaluation_completed_counter: Optional[Counter] = None
    _version_saved_counter: Optional[Counter] = None
    _diff_comparison_counter: Optional[Counter] = None
    _tracer: Any

    def __init__(
        self,
        repository: DiagramRepository,
        storage: DiagramStorage,
        parser: PlantUMLParser,
    ) -> None:
        self._repository = repository
        self._storage = storage
        self._parser = parser

        # Initialize OpenTelemetry metrics and tracer
        try:
            meter = metrics.get_meter(__name__)
            self._parsing_duration = meter.create_histogram(
                "plantuml_parsing_duration_seconds",
                description="Time taken to parse PlantUML files",
                unit="s",
            )
            self._diagram_uploaded_counter = meter.create_counter(
                "diagram_uploaded_total",
                description="Total number of diagrams uploaded",
            )
            self._parsing_succeeded_counter = meter.create_counter(
                "parsing_succeeded_total",
                description="Total number of successful parsing operations",
            )
            self._parsing_failed_counter = meter.create_counter(
                "parsing_failed_total",
                description="Total number of failed parsing operations",
            )
            self._evaluation_completed_counter = meter.create_counter(
                "evaluation_completed_total",
                description="Total number of completed evaluation cycles",
            )
            self._version_saved_counter = meter.create_counter(
                "version_saved_total",
                description="Total number of versions saved",
            )
            self._diff_comparison_counter = meter.create_counter(
                "diff_comparison_total",
                description="Total number of diagram diff comparisons",
            )
            self._tracer = trace.get_tracer(__name__)
        except Exception:
            # Fallback to no-op if telemetry is not available
            self._parsing_duration = None
            self._diagram_uploaded_counter = None
            self._parsing_succeeded_counter = None
            self._parsing_failed_counter = None
            self._evaluation_completed_counter = None
            self._version_saved_counter = None
            self._diff_comparison_counter = None
            self._tracer = trace.NoOpTracer()

    def register_diagram(self, diagram: Diagram) -> Diagram:
        return self._repository.add(diagram)

    def get_diagram(self, diagram_id: UUID) -> Diagram | None:
        return self._repository.get(diagram_id)

    def list_diagrams(self) -> Iterable[Diagram]:
        return self._repository.list()

    def upload_diagram(
        self, filename: str, content: bytes, display_name: str | None = None
    ) -> Diagram:
        with self._tracer.start_as_current_span("diagram.upload") as span:
            content_str = content.decode("utf-8")
            file_size = len(content)
            checksum = sha256(content).hexdigest()
            existing = self._repository.find_by_checksum(checksum)
            if existing:
                raise DiagramAlreadyExistsError(existing.id)

            # Store content in DB, source_url is now just a reference/identifier
            source_url = f"diagram://{filename}"

            diagram = Diagram(
                name=display_name or filename,
                source_url=source_url,
                content=content_str,
                checksum=checksum,
            )
            diagram = self._repository.add(diagram)

            # Track analytics event: diagram_uploaded
            if self._diagram_uploaded_counter:
                self._diagram_uploaded_counter.add(
                    1,
                    attributes={
                        "file_size_bytes": file_size,
                        "diagram_id": str(diagram.id),
                    },
                )

            span.set_attribute("diagram.id", str(diagram.id))
            span.set_attribute("file.size_bytes", file_size)
            span.add_event("diagram_uploaded", {"diagram_id": str(diagram.id)})

            return diagram

    def parse_diagram(
        self, diagram_id: UUID
    ) -> tuple[list[Component], list[Relationship]]:
        with self._tracer.start_as_current_span("diagram.parse") as span:
            start_time = time.time()
            diagram = self._repository.get(diagram_id)
            if not diagram:
                raise DiagramNotFoundError(f"Diagram {diagram_id} not found")

            # Read content from diagram (stored in DB)
            if not diagram.content:
                diagram.mark_failed()
                self._repository.update(diagram)
                raise ParseError(f"Diagram {diagram_id} has no content")

            file_size = len(diagram.content) if diagram.content else 0

            # Parse content
            try:
                components, relationships = self._parser.parse(diagram.content)
                parsing_duration = time.time() - start_time
                component_count = len(components)
                relationship_count = len(relationships)

                # Track observability metric: parsing duration (SLO 2)
                if self._parsing_duration:
                    self._parsing_duration.record(
                        parsing_duration,
                        attributes={
                            "file_size_bytes": file_size,
                            "component_count": component_count,
                            "status": "success",
                        },
                    )

                # Track analytics event: parsing_succeeded
                if self._parsing_succeeded_counter:
                    self._parsing_succeeded_counter.add(
                        1,
                        attributes={
                            "diagram_id": str(diagram_id),
                            "component_count": component_count,
                            "relationship_count": relationship_count,
                        },
                    )

                span.set_attribute("parsing.duration_seconds", parsing_duration)
                span.set_attribute("parsing.component_count", component_count)
                span.set_attribute("parsing.relationship_count", relationship_count)
                span.add_event(
                    "parsing_succeeded",
                    {
                        "diagram_id": str(diagram_id),
                        "component_count": component_count,
                    },
                )

            except Exception as exc:
                parsing_duration = time.time() - start_time
                diagram.mark_failed()
                self._repository.update(diagram)

                # Track observability metric: parsing duration (failed)
                if self._parsing_duration:
                    self._parsing_duration.record(
                        parsing_duration,
                        attributes={
                            "file_size_bytes": file_size,
                            "status": "error",
                            "error_type": type(exc).__name__,
                        },
                    )

                # Track analytics event: parsing_failed
                if self._parsing_failed_counter:
                    self._parsing_failed_counter.add(
                        1,
                        attributes={
                            "diagram_id": str(diagram_id),
                            "error_type": type(exc).__name__,
                        },
                    )

                span.set_status(trace.Status(trace.StatusCode.ERROR, str(exc)))
                span.add_event("parsing_failed", {"error": str(exc)})
                raise ParseError(f"Failed to parse diagram: {exc}") from exc

            for component in components:
                component.diagram_id = diagram_id

            id_mapping = self._sync_components(diagram_id, components)

            for relationship in relationships:
                relationship.diagram_id = diagram_id
                if relationship.source_component_id in id_mapping:
                    relationship.source_component_id = id_mapping[
                        relationship.source_component_id
                    ]
                if relationship.target_component_id in id_mapping:
                    relationship.target_component_id = id_mapping[
                        relationship.target_component_id
                    ]

            # Replace relationships atomically (components are upserted)
            self._repository.delete_relationships(diagram_id)
            self._repository.add_relationships(relationships)

            # Update diagram status
            diagram.mark_parsed()
            self._repository.update(diagram)

            # Track analytics event: matrix_populated (after parsing)
            span.add_event(
                "matrix_populated",
                {
                    "diagram_id": str(diagram_id),
                    "component_count": component_count,
                },
            )

            return list(components), list(relationships)

    def _sync_components(
        self, diagram_id: UUID, components: Sequence[Component]
    ) -> Dict[UUID, UUID]:
        existing_components = self._repository.get_components(diagram_id)
        existing_by_name = {
            self._normalize_name(component.name): component
            for component in existing_components
        }

        final_ids: set[UUID] = set()
        components_to_add: list[Component] = []
        components_to_update: list[Component] = []
        id_mapping: Dict[UUID, UUID] = {}

        for component in components:
            original_id = component.id
            normalized_name = self._normalize_name(component.name)
            if normalized_name in existing_by_name:
                existing = existing_by_name[normalized_name]
                component.id = existing.id
                final_ids.add(existing.id)
                id_mapping[original_id] = existing.id

                if (
                    existing.name != component.name
                    or existing.type != component.type
                    or existing.metadata != component.metadata
                ):
                    components_to_update.append(component)
            else:
                stable_id = self._stable_component_id(diagram_id, component)
                component.id = stable_id
                final_ids.add(stable_id)
                id_mapping[original_id] = stable_id
                components_to_add.append(component)

        obsolete_ids = [
            component.id
            for component in existing_components
            if component.id not in final_ids
        ]

        if obsolete_ids:
            self._repository.delete_components(diagram_id, obsolete_ids)

        if components_to_add:
            self._repository.add_components(components_to_add)

        if components_to_update:
            self._repository.update_components(components_to_update)

        return id_mapping

    @staticmethod
    def _stable_component_id(diagram_id: UUID, component: Component) -> UUID:
        """Return deterministic UUID per diagram/component name+type."""
        key = f"{component.name.strip().lower()}::{component.type.value}"
        return uuid5(diagram_id, key)

    @staticmethod
    def _normalize_name(name: str) -> str:
        return " ".join(name.split()).lower()

    def diff_diagrams(
        self, base_diagram_id: UUID, target_diagram_id: UUID
    ) -> tuple[list[ComponentDiff], list[RelationshipDiff]]:
        with self._tracer.start_as_current_span("diagram.diff") as span:
            base = self._repository.get(base_diagram_id)
            target = self._repository.get(target_diagram_id)
            if base is None or target is None:
                missing_id = base_diagram_id if base is None else target_diagram_id
                raise DiagramNotFoundError(f"Diagram {missing_id} not found")

            base_components = self._repository.get_components(base_diagram_id)
            target_components = self._repository.get_components(target_diagram_id)

            components_diff = self._build_component_diff(
                base_components=base_components, target_components=target_components
            )

            base_relationships = self._repository.get_relationships(base_diagram_id)
            target_relationships = self._repository.get_relationships(target_diagram_id)

            relationships_diff = self._build_relationship_diff(
                base_components=base_components,
                target_components=target_components,
                base_relationships=base_relationships,
                target_relationships=target_relationships,
            )

            # Track analytics event: diff_comparison
            if self._diff_comparison_counter:
                self._diff_comparison_counter.add(
                    1,
                    attributes={
                        "base_diagram_id": str(base_diagram_id),
                        "target_diagram_id": str(target_diagram_id),
                        "component_changes": len(components_diff),
                        "relationship_changes": len(relationships_diff),
                    },
                )

            span.set_attribute("diff.component_changes", len(components_diff))
            span.set_attribute("diff.relationship_changes", len(relationships_diff))
            span.add_event(
                "diff_comparison",
                {
                    "base_diagram_id": str(base_diagram_id),
                    "target_diagram_id": str(target_diagram_id),
                },
            )

            return components_diff, relationships_diff

    def _build_component_diff(
        self,
        base_components: Sequence[Component],
        target_components: Sequence[Component],
    ) -> list[ComponentDiff]:
        base_by_name = {
            self._normalize_name(component.name): component
            for component in base_components
        }
        target_by_name = {
            self._normalize_name(component.name): component
            for component in target_components
        }

        diffs: list[ComponentDiff] = []

        # Added or modified
        for name_key, target_component in target_by_name.items():
            if name_key not in base_by_name:
                diffs.append(
                    ComponentDiff(
                        name=target_component.name,
                        change_type="added",
                        new_type=target_component.type,
                    )
                )
                continue

            base_component = base_by_name[name_key]
            if base_component.type != target_component.type:
                diffs.append(
                    ComponentDiff(
                        name=target_component.name,
                        change_type="modified",
                        previous_type=base_component.type,
                        new_type=target_component.type,
                    )
                )

        # Removed
        for name_key, base_component in base_by_name.items():
            if name_key not in target_by_name:
                diffs.append(
                    ComponentDiff(
                        name=base_component.name,
                        change_type="removed",
                        previous_type=base_component.type,
                    )
                )

        return diffs

    def _build_relationship_diff(
        self,
        base_components: Sequence[Component],
        target_components: Sequence[Component],
        base_relationships: Sequence[Relationship],
        target_relationships: Sequence[Relationship],
    ) -> list[RelationshipDiff]:
        base_names_by_id = {
            component.id: component.name for component in base_components
        }
        target_names_by_id = {
            component.id: component.name for component in target_components
        }

        def _relationship_key(source_name: str, target_name: str) -> tuple[str, str]:
            return (
                self._normalize_name(source_name),
                self._normalize_name(target_name),
            )

        base_by_key: dict[tuple[str, str], Relationship] = {}
        for relationship in base_relationships:
            source_name = base_names_by_id.get(relationship.source_component_id)
            target_name = base_names_by_id.get(relationship.target_component_id)
            if source_name and target_name:
                base_by_key[_relationship_key(source_name, target_name)] = relationship

        diffs: list[RelationshipDiff] = []

        for relationship in target_relationships:
            source_name = target_names_by_id.get(relationship.source_component_id)
            target_name = target_names_by_id.get(relationship.target_component_id)
            if not source_name or not target_name:
                continue

            key = _relationship_key(source_name, target_name)
            if key not in base_by_key:
                diffs.append(
                    RelationshipDiff(
                        source=source_name,
                        target=target_name,
                        change_type="added",
                        new_label=relationship.label,
                        new_direction=relationship.direction,
                    )
                )
                continue

            base_relationship = base_by_key.pop(key)
            if (
                base_relationship.label != relationship.label
                or base_relationship.direction != relationship.direction
            ):
                diffs.append(
                    RelationshipDiff(
                        source=source_name,
                        target=target_name,
                        change_type="modified",
                        previous_label=base_relationship.label,
                        new_label=relationship.label,
                        previous_direction=base_relationship.direction,
                        new_direction=relationship.direction,
                    )
                )

        # Relationships removed from target
        for key, relationship in base_by_key.items():
            source_name = base_names_by_id.get(relationship.source_component_id)
            target_name = base_names_by_id.get(relationship.target_component_id)
            if source_name and target_name:
                diffs.append(
                    RelationshipDiff(
                        source=source_name,
                        target=target_name,
                        change_type="removed",
                        previous_label=relationship.label,
                        previous_direction=relationship.direction,
                    )
                )

        return diffs
