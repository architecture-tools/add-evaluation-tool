from __future__ import annotations

import re
from typing import Sequence

from app.domain.diagrams.entities import Component, ComponentType, Relationship, RelationshipDirection
from app.domain.diagrams.exceptions import ParseError
from app.domain.diagrams.parsers import PlantUMLParser


class RegexPlantUMLParser(PlantUMLParser):
    """Simple regex-based parser for PlantUML component diagrams."""

    def parse(self, content: str) -> tuple[Sequence[Component], Sequence[Relationship]]:
        """
        Parse PlantUML content to extract components and relationships.

        Supports:
        - Component declarations: [Component Name] or [Component Name] as Alias
        - Database declarations: database "Database Name" or database "Name" as Alias
        - Relationships: Component1 --> Component2 : label
        - Bidirectional: Component1 <--> Component2
        """
        if not content.strip():
            raise ParseError("Empty PlantUML content")

        components, alias_to_name = self._extract_components(content)
        relationships = self._extract_relationships(content, components, alias_to_name)

        return components, relationships

    def _extract_components(self, content: str) -> list[Component]:
        components = []
        alias_to_name: dict[str, str] = {}  # alias -> name

        # Match [Component Name] or [Component Name] as Alias
        component_pattern = r'\[([^\]]+)\](?:\s+as\s+(\w+))?'
        for match in re.finditer(component_pattern, content):
            name = match.group(1).strip()
            alias = match.group(2)
            if alias:
                alias_to_name[alias] = name
            components.append((name, ComponentType.COMPONENT, alias))

        # Match database "Database Name" or database "Name" as Alias
        database_pattern = r'database\s+"([^"]+)"(?:\s+as\s+(\w+))?'
        for match in re.finditer(database_pattern, content, re.IGNORECASE):
            name = match.group(1).strip()
            alias = match.group(2)
            if alias:
                alias_to_name[alias] = name
            components.append((name, ComponentType.DATABASE, alias))

        # Match queue "Queue Name" or queue "Name" as Alias
        queue_pattern = r'queue\s+"([^"]+)"(?:\s+as\s+(\w+))?'
        for match in re.finditer(queue_pattern, content, re.IGNORECASE):
            name = match.group(1).strip()
            alias = match.group(2)
            if alias:
                alias_to_name[alias] = name
            components.append((name, ComponentType.QUEUE, alias))

        # Create Component entities (without diagram_id for now, will be set later)
        result = []
        seen_names = set()
        for name, comp_type, alias in components:
            if name not in seen_names:
                result.append(Component(
                    diagram_id=None,  # type: ignore
                    name=name,
                    type=comp_type,
                ))
                seen_names.add(name)
                if alias:
                    alias_to_name[alias] = name

        return result, alias_to_name

    def _extract_relationships(
        self, content: str, components: list[Component], alias_to_name: dict[str, str]
    ) -> list[Relationship]:
        relationships = []
        name_to_component = {comp.name: comp for comp in components}

        # Match Component1 --> Component2 : label
        # Also handle Component1 <--> Component2 (bidirectional)
        relationship_pattern = r'(\w+)\s*(<?-+>+)\s*(\w+)(?:\s*:\s*([^\n]+))?'
        for match in re.finditer(relationship_pattern, content):
            source_alias = match.group(1).strip()
            arrow = match.group(2).strip()
            target_alias = match.group(3).strip()
            label = match.group(4).strip() if match.group(4) else None

            # Determine direction
            direction = RelationshipDirection.BIDIRECTIONAL if '<' in arrow else RelationshipDirection.UNIDIRECTIONAL

            # Resolve aliases to component names
            source_name = alias_to_name.get(source_alias, source_alias)
            target_name = alias_to_name.get(target_alias, target_alias)

            # Find components by name
            source_comp = name_to_component.get(source_name)
            target_comp = name_to_component.get(target_name)

            if source_comp and target_comp:
                relationships.append(Relationship(
                    diagram_id=None,  # type: ignore
                    source_component_id=source_comp.id,
                    target_component_id=target_comp.id,
                    label=label,
                    direction=direction,
                ))

        return relationships
