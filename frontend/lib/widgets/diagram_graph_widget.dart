import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import '../network/src/api.dart';
import '../theme/app_theme.dart';

/// Change type for highlighting in diff view
enum ComponentChangeType {
  added,
  removed,
  modified,
  unchanged,
}

/// Widget to visualize a parsed diagram as a graph
class DiagramGraphWidget extends StatefulWidget {
  const DiagramGraphWidget({
    super.key,
    required this.components,
    required this.relationships,
    this.title,
    this.height = 400,
    this.componentChangeTypes,
    this.relationshipChangeTypes,
    this.showEdgeLabels = true,
  });

  final List<ComponentResponse> components;
  final List<RelationshipResponse> relationships;
  final String? title;
  final double height;
  final Map<String, ComponentChangeType>? componentChangeTypes;
  final Map<String, ComponentChangeType>? relationshipChangeTypes;
  final bool showEdgeLabels;

  @override
  State<DiagramGraphWidget> createState() => _DiagramGraphWidgetState();
}

class _DiagramGraphWidgetState extends State<DiagramGraphWidget> {
  final TransformationController _transformationController =
      TransformationController();
  double _scale = 1.0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize transformation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.components.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No components to display',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    final graph = Graph();
    final nodeMap = <String, Node>{};

    // Create nodes for all components
    for (final component in widget.components) {
      final node = Node.Id(component.id);
      nodeMap[component.id] = node;
      graph.addNode(node);
    }

    // Create edges for all relationships
    for (final relationship in widget.relationships) {
      final sourceNode = nodeMap[relationship.sourceComponentId];
      final targetNode = nodeMap[relationship.targetComponentId];

      if (sourceNode != null && targetNode != null) {
        graph.addEdge(sourceNode, targetNode);
      }
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null) ...[
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  _buildZoomControls(),
                ],
              ),
            ),
            const Divider(height: 1),
          ] else
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildZoomControls(),
            ),
          Expanded(
            child: _isInitialized
                ? ClipRect(
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.1,
                      maxScale: 4.0,
                      boundaryMargin: const EdgeInsets.all(200),
                      onInteractionUpdate: (details) {
                        if (mounted) {
                          setState(() {
                            _scale = _transformationController.value
                                .getMaxScaleOnAxis();
                          });
                        }
                      },
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final config = FruchtermanReingoldConfiguration()
                            ..iterations = 1000;

                          // Use larger size to prevent clipping with padding
                          final graphWidth = constraints.maxWidth > 0
                              ? (constraints.maxWidth * 1.5).toDouble()
                              : 1200.0;
                          final graphHeight = constraints.maxHeight > 0
                              ? (constraints.maxHeight * 1.5).toDouble()
                              : 900.0;

                          return Container(
                            width: graphWidth,
                            height: graphHeight,
                            padding: const EdgeInsets.all(100),
                            child: GraphView(
                              graph: graph,
                              algorithm: FruchtermanReingoldAlgorithm(config),
                              paint: Paint()
                                ..color = AppTheme.borderColor
                                ..strokeWidth = 2
                                ..style = PaintingStyle.stroke,
                              builder: (node) {
                                final component = widget.components.firstWhere(
                                  (c) => c.id == node.key?.value,
                                  orElse: () => ComponentResponse(
                                    id: node.key?.value ?? '',
                                    name: 'Unknown',
                                    type: ComponentType.component,
                                  ),
                                );
                                final changeType = widget
                                        .componentChangeTypes?[component.id] ??
                                    ComponentChangeType.unchanged;
                                return _buildNodeWidget(component, changeType);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildZoomControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.zoom_out, size: 18),
          onPressed: () {
            _transformationController.value = Matrix4.identity()
              ..scale(_scale * 0.8);
            setState(() {
              _scale *= 0.8;
            });
          },
          tooltip: 'Zoom out',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '${(_scale * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.zoom_in, size: 18),
          onPressed: () {
            _transformationController.value = Matrix4.identity()
              ..scale(_scale * 1.2);
            setState(() {
              _scale *= 1.2;
            });
          },
          tooltip: 'Zoom in',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.refresh, size: 18),
          onPressed: () {
            _transformationController.value = Matrix4.identity();
            setState(() {
              _scale = 1.0;
            });
          },
          tooltip: 'Reset view',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildNodeWidget(
    ComponentResponse component,
    ComponentChangeType changeType,
  ) {
    final baseColor = _getComponentTypeColor(component.type);
    final icon = _getComponentTypeIcon(component.type);

    // Determine highlight color and style based on change type
    Color highlightColor;
    double borderWidth;
    List<BoxShadow>? shadows;
    bool isDashed = false;
    IconData? changeIcon;

    switch (changeType) {
      case ComponentChangeType.added:
        highlightColor = AppTheme.green;
        borderWidth = 4;
        shadows = [
          BoxShadow(
            color: AppTheme.green.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 3,
          ),
        ];
        changeIcon = Icons.add_circle;
        break;
      case ComponentChangeType.removed:
        highlightColor = AppTheme.red;
        borderWidth = 4;
        isDashed = true;
        shadows = [
          BoxShadow(
            color: AppTheme.red.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ];
        changeIcon = Icons.remove_circle;
        break;
      case ComponentChangeType.modified:
        highlightColor = AppTheme.yellow;
        borderWidth = 4;
        shadows = [
          BoxShadow(
            color: AppTheme.yellow.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ];
        changeIcon = Icons.edit;
        break;
      case ComponentChangeType.unchanged:
        highlightColor = baseColor;
        borderWidth = 2;
        shadows = null;
        changeIcon = null;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: changeType == ComponentChangeType.removed
            ? baseColor.withOpacity(0.05)
            : baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: isDashed
            ? Border.all(
                color: highlightColor,
                width: borderWidth,
                style: BorderStyle
                    .solid, // Note: Flutter doesn't support dashed borders directly
              )
            : Border.all(
                color: highlightColor,
                width: borderWidth,
              ),
        boxShadow: shadows,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (changeIcon != null) ...[
                Icon(changeIcon, size: 14, color: highlightColor),
                const SizedBox(width: 4),
              ],
              Icon(icon,
                  size: 16,
                  color: changeType == ComponentChangeType.removed
                      ? AppTheme.textSecondary
                      : baseColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  component.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: changeType == ComponentChangeType.removed
                        ? AppTheme.textSecondary
                        : baseColor,
                    decoration: changeType == ComponentChangeType.removed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              component.type.value.toUpperCase(),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: changeType == ComponentChangeType.removed
                    ? AppTheme.textSecondary
                    : baseColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getComponentTypeColor(ComponentType type) {
    switch (type.value) {
      case 'component':
        return AppTheme.blue;
      case 'database':
        return AppTheme.green;
      case 'service':
        return AppTheme.primaryPurple;
      case 'api':
      case 'interface':
        return AppTheme.yellow;
      case 'actor':
        return AppTheme.orange;
      case 'package':
        return AppTheme.primaryPurpleLight;
      case 'queue':
        return AppTheme.red;
      case 'system':
        return AppTheme.primaryPurpleDark;
      case 'external':
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getComponentTypeIcon(ComponentType type) {
    switch (type.value) {
      case 'database':
        return Icons.storage;
      case 'service':
        return Icons.cloud;
      case 'api':
      case 'interface':
        return Icons.api;
      case 'actor':
        return Icons.person;
      case 'package':
        return Icons.inventory_2;
      case 'queue':
        return Icons.queue;
      case 'system':
        return Icons.computer;
      case 'external':
        return Icons.public;
      default:
        return Icons.widgets;
    }
  }
}
