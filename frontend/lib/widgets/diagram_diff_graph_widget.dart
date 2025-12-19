import 'package:flutter/material.dart';
import '../network/src/api.dart';
import '../theme/app_theme.dart';
import 'diagram_graph_widget.dart';

/// Widget to visualize diagram diffs side-by-side as graphs
class DiagramDiffGraphWidget extends StatelessWidget {
  const DiagramDiffGraphWidget({
    super.key,
    required this.baseDiagram,
    required this.targetDiagram,
    required this.diff,
    this.height = 400,
  });

  final ParseDiagramResponse? baseDiagram;
  final ParseDiagramResponse? targetDiagram;
  final DiagramDiffResponse diff;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        SizedBox(
          height: height,
          child: Row(
            children: [
              Expanded(
                child: _buildGraphWithHighlights(
                  baseDiagram,
                  diff,
                  'Base',
                  true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGraphWithHighlights(
                  targetDiagram,
                  diff,
                  'Target',
                  false,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.red.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.remove_circle,
                        size: 16, color: AppTheme.red),
                    const SizedBox(width: 6),
                    Text(
                      'Base Diagram',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Shows removed components (red) and modified (yellow)',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.add_circle,
                        size: 16, color: AppTheme.green),
                    const SizedBox(width: 6),
                    Text(
                      'Target Diagram',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Shows added components (green) and modified (yellow)',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(Icons.add_circle, AppTheme.green, 'Added'),
          const SizedBox(width: 24),
          _buildLegendItem(Icons.remove_circle, AppTheme.red, 'Removed'),
          const SizedBox(width: 24),
          _buildLegendItem(Icons.edit, AppTheme.yellow, 'Modified'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGraphWithHighlights(
    ParseDiagramResponse? diagram,
    DiagramDiffResponse diff,
    String title,
    bool isBase,
  ) {
    if (diagram == null) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.textSecondary,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Diagram not parsed',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'Parse the diagram to view graph',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Build maps of component/relationship IDs to their change types
    final componentChangeTypes = <String, ComponentChangeType>{};
    final relationshipChangeTypes = <String, ComponentChangeType>{};

    // Initialize all components as unchanged
    for (final component in diagram.components) {
      componentChangeTypes[component.id] = ComponentChangeType.unchanged;
    }

    // Initialize all relationships as unchanged
    for (final relationship in diagram.relationships) {
      relationshipChangeTypes[relationship.id] = ComponentChangeType.unchanged;
    }

    // Process component diffs
    for (final componentDiff in diff.components) {
      // Find component by name in the diagram
      final component = diagram.components.firstWhere(
        (c) => c.name == componentDiff.name,
        orElse: () => ComponentResponse(
          id: '',
          name: componentDiff.name,
          type: ComponentType.component,
        ),
      );

      if (component.id.isNotEmpty) {
        final changeTypeValue = componentDiff.changeType.value;
        if (changeTypeValue == 'removed' && isBase) {
          componentChangeTypes[component.id] = ComponentChangeType.removed;
        } else if (changeTypeValue == 'added' && !isBase) {
          componentChangeTypes[component.id] = ComponentChangeType.added;
        } else if (changeTypeValue == 'modified') {
          componentChangeTypes[component.id] = ComponentChangeType.modified;
        }
      }
    }

    // Process relationship diffs
    for (final relDiff in diff.relationships) {
      // Find relationship by source and target
      final relationship = diagram.relationships.firstWhere(
        (r) =>
            r.sourceComponentId == relDiff.source_ &&
            r.targetComponentId == relDiff.target,
        orElse: () => RelationshipResponse(
          id: '',
          sourceComponentId: relDiff.source_,
          targetComponentId: relDiff.target,
          direction: RelationshipDirection.unidirectional,
        ),
      );

      if (relationship.id.isNotEmpty) {
        final changeTypeValue = relDiff.changeType.value;
        if (changeTypeValue == 'removed' && isBase) {
          relationshipChangeTypes[relationship.id] =
              ComponentChangeType.removed;
        } else if (changeTypeValue == 'added' && !isBase) {
          relationshipChangeTypes[relationship.id] = ComponentChangeType.added;
        } else if (changeTypeValue == 'modified') {
          relationshipChangeTypes[relationship.id] =
              ComponentChangeType.modified;
        }
      }
    }

    return DiagramGraphWidget(
      components: diagram.components,
      relationships: diagram.relationships,
      title: title,
      height: height,
      componentChangeTypes: componentChangeTypes,
      relationshipChangeTypes: relationshipChangeTypes,
      showEdgeLabels: true,
    );
  }
}
