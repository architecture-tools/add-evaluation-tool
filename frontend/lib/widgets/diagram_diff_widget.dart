import 'package:flutter/material.dart';
import '../network/src/api.dart';
import '../theme/app_theme.dart';
import 'diagram_diff_graph_widget.dart';

class DiagramDiffWidget extends StatefulWidget {
  const DiagramDiffWidget({
    super.key,
    required this.diff,
    required this.baseDiagramName,
    required this.targetDiagramName,
    this.baseDiagram,
    this.targetDiagram,
  });

  final DiagramDiffResponse diff;
  final String baseDiagramName;
  final String targetDiagramName;
  final ParseDiagramResponse? baseDiagram;
  final ParseDiagramResponse? targetDiagram;

  @override
  State<DiagramDiffWidget> createState() => _DiagramDiffWidgetState();
}

class _DiagramDiffWidgetState extends State<DiagramDiffWidget> {
  bool _showGraphView = false;

  @override
  Widget build(BuildContext context) {
    final hasComponents = widget.diff.components.isNotEmpty;
    final hasRelationships = widget.diff.relationships.isNotEmpty;

    if (!hasComponents && !hasRelationships) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No differences found between these diagrams.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        _buildViewToggle(),
        const SizedBox(height: 16),
        Expanded(
          child: _showGraphView &&
                  widget.baseDiagram != null &&
                  widget.targetDiagram != null
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DiagramDiffGraphWidget(
                      baseDiagram: widget.baseDiagram,
                      targetDiagram: widget.targetDiagram,
                      diff: widget.diff,
                      height: 500,
                    ),
                  ),
                )
              : _buildTextView(),
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.borderColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            'Text View',
            Icons.text_fields,
            !_showGraphView,
            () => setState(() => _showGraphView = false),
          ),
          _buildToggleButton(
            'Graph View',
            Icons.account_tree,
            _showGraphView,
            () {
              if (widget.baseDiagram != null && widget.targetDiagram != null) {
                setState(() => _showGraphView = true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Please parse both diagrams to view graph comparison'),
                    backgroundColor: AppTheme.yellow,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (widget.diff.components.isNotEmpty) ...[
              _buildSectionTitle('Components', widget.diff.components.length),
              const SizedBox(height: 12),
              ...widget.diff.components
                  .map((component) => _buildComponentDiff(component)),
              const SizedBox(height: 24),
            ],
            if (widget.diff.relationships.isNotEmpty) ...[
              _buildSectionTitle(
                  'Relationships', widget.diff.relationships.length),
              const SizedBox(height: 12),
              ...widget.diff.relationships
                  .map((rel) => _buildRelationshipDiff(rel)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child:
              _buildDiagramLabel('Base', widget.baseDiagramName, AppTheme.blue),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(Icons.compare_arrows, color: AppTheme.textSecondary),
        ),
        Expanded(
          child: _buildDiagramLabel(
              'Target', widget.targetDiagramName, AppTheme.green),
        ),
      ],
    );
  }

  Widget _buildDiagramLabel(String label, String name, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComponentDiff(ComponentDiffResponse component) {
    final changeType = component.changeType;
    Color backgroundColor;
    IconData icon;
    String label;

    switch (changeType.value) {
      case 'added':
        backgroundColor = AppTheme.green.withOpacity(0.1);
        icon = Icons.add_circle;
        label = 'Added';
        break;
      case 'removed':
        backgroundColor = AppTheme.red.withOpacity(0.1);
        icon = Icons.remove_circle;
        label = 'Removed';
        break;
      case 'modified':
        backgroundColor = AppTheme.yellow.withOpacity(0.1);
        icon = Icons.edit;
        label = 'Modified';
        break;
      default:
        backgroundColor = AppTheme.borderColor;
        icon = Icons.help;
        label = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: backgroundColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _getChangeTypeColor(changeType)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      component.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getChangeTypeColor(changeType).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getChangeTypeColor(changeType),
                        ),
                      ),
                    ),
                  ],
                ),
                if (component.previousType != null ||
                    component.newType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _buildTypeChangeText(
                        component.previousType, component.newType),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelationshipDiff(RelationshipDiffResponse rel) {
    final changeType = rel.changeType;
    Color backgroundColor;
    IconData icon;
    String label;

    switch (changeType.value) {
      case 'added':
        backgroundColor = AppTheme.green.withOpacity(0.1);
        icon = Icons.add_circle;
        label = 'Added';
        break;
      case 'removed':
        backgroundColor = AppTheme.red.withOpacity(0.1);
        icon = Icons.remove_circle;
        label = 'Removed';
        break;
      case 'modified':
        backgroundColor = AppTheme.yellow.withOpacity(0.1);
        icon = Icons.edit;
        label = 'Modified';
        break;
      default:
        backgroundColor = AppTheme.borderColor;
        icon = Icons.help;
        label = 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: backgroundColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _getChangeTypeColor(changeType)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${rel.source_} → ${rel.target}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getChangeTypeColor(changeType).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getChangeTypeColor(changeType),
                        ),
                      ),
                    ),
                  ],
                ),
                if (rel.previousLabel != null ||
                    rel.newLabel != null ||
                    rel.previousDirection != null ||
                    rel.newDirection != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _buildRelationshipChangeText(rel),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getChangeTypeColor(dynamic changeType) {
    switch (changeType.value) {
      case 'added':
        return AppTheme.green;
      case 'removed':
        return AppTheme.red;
      case 'modified':
        return AppTheme.yellow;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _buildTypeChangeText(ComponentType? previous, ComponentType? newType) {
    if (previous != null && newType != null) {
      return '${previous.value} → ${newType.value}';
    } else if (previous != null) {
      return 'Was: ${previous.value}';
    } else if (newType != null) {
      return 'Now: ${newType.value}';
    }
    return '';
  }

  String _buildRelationshipChangeText(RelationshipDiffResponse rel) {
    final parts = <String>[];
    if (rel.previousLabel != null || rel.newLabel != null) {
      if (rel.previousLabel != null && rel.newLabel != null) {
        parts.add('Label: ${rel.previousLabel} → ${rel.newLabel}');
      } else if (rel.previousLabel != null) {
        parts.add('Was labeled: ${rel.previousLabel}');
      } else if (rel.newLabel != null) {
        parts.add('Now labeled: ${rel.newLabel}');
      }
    }
    if (rel.previousDirection != null || rel.newDirection != null) {
      if (rel.previousDirection != null && rel.newDirection != null) {
        parts.add(
            'Direction: ${rel.previousDirection!.value} → ${rel.newDirection!.value}');
      } else if (rel.previousDirection != null) {
        parts.add('Was: ${rel.previousDirection!.value}');
      } else if (rel.newDirection != null) {
        parts.add('Now: ${rel.newDirection!.value}');
      }
    }
    return parts.join(' • ');
  }
}
