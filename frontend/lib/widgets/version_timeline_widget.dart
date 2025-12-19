import 'package:flutter/material.dart';
import '../network/src/api.dart';
import '../services/diagram_repository.dart';
import '../theme/app_theme.dart';
import '../models/mock_models.dart';
import 'diagram_diff_widget.dart';

class VersionTimelineWidget extends StatelessWidget {
  const VersionTimelineWidget({
    super.key,
    required this.timeline,
    this.diagrams = const [],
    DiagramRepository? diagramRepository,
  }) : _diagramRepository = diagramRepository;

  final List<VersionInfo> timeline;
  final List<DiagramResponse> diagrams;
  final DiagramRepository? _diagramRepository;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Version Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Evolution over time',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (timeline.isEmpty)
              const Text(
                'Timeline will appear after the first diagram is processed.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              )
            else
              ...timeline.asMap().entries.map((entry) {
                final index = entry.key;
                final version = entry.value;
                final isLast = index == timeline.length - 1;
                final diagram =
                    index < diagrams.length ? diagrams[index] : null;
                return _VersionItem(
                  version: version.version,
                  timeAgo: version.timeAgo,
                  description: version.description,
                  changes: version.changes,
                  score: version.score,
                  trend: version.trend,
                  showLine: !isLast,
                  diagram: diagram,
                  canCompare: index > 0 && diagrams.length > index,
                  baseDiagram: index > 0 && diagrams.length > index
                      ? diagrams[index]
                      : null,
                  onCompare: index > 0 && diagrams.length > index
                      ? () => _showDiffDialog(context, diagrams[index],
                          diagrams[index - 1], _diagramRepository)
                      : null,
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showDiffDialog(
    BuildContext context,
    DiagramResponse targetDiagram,
    DiagramResponse baseDiagram,
    DiagramRepository? diagramRepository,
  ) {
    showDialog(
      context: context,
      builder: (context) => _DiffDialog(
        baseDiagram: baseDiagram,
        targetDiagram: targetDiagram,
        diagramRepository: diagramRepository,
      ),
    );
  }
}

class _DiffDialog extends StatefulWidget {
  const _DiffDialog({
    required this.baseDiagram,
    required this.targetDiagram,
    DiagramRepository? diagramRepository,
  }) : _diagramRepository = diagramRepository;

  final DiagramResponse baseDiagram;
  final DiagramResponse targetDiagram;
  final DiagramRepository? _diagramRepository;

  @override
  State<_DiffDialog> createState() => _DiffDialogState();
}

class _DiffDialogState extends State<_DiffDialog> {
  late final DiagramRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = widget._diagramRepository ?? DiagramRepository();
    _loadData();
  }

  DiagramDiffResponse? _diff;
  ParseDiagramResponse? _baseParsedDiagram;
  ParseDiagramResponse? _targetParsedDiagram;
  bool _isLoading = true;
  String? _error;

  Future<void> _loadData() async {
    try {
      // Load diff and parsed diagrams in parallel
      final results = await Future.wait([
        _repository.diffDiagrams(
          widget.baseDiagram.id,
          widget.targetDiagram.id,
        ),
        _repository.parseDiagram(widget.baseDiagram.id).catchError((_) => null),
        _repository
            .parseDiagram(widget.targetDiagram.id)
            .catchError((_) => null),
      ]);

      if (mounted) {
        setState(() {
          _diff = results[0] as DiagramDiffResponse?;
          _baseParsedDiagram = results[1] as ParseDiagramResponse?;
          _targetParsedDiagram = results[2] as ParseDiagramResponse?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1800, maxHeight: 1200),
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Diagram Comparison',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppTheme.red,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load diff',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _diff != null
                          ? DiagramDiffWidget(
                              diff: _diff!,
                              baseDiagramName: widget.baseDiagram.name,
                              targetDiagramName: widget.targetDiagram.name,
                              baseDiagram: _baseParsedDiagram,
                              targetDiagram: _targetParsedDiagram,
                            )
                          : const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No diff data available',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VersionItem extends StatelessWidget {
  final String version;
  final String timeAgo;
  final String description;
  final String changes;
  final double score;
  final VersionTrend? trend;
  final bool showLine;
  final DiagramResponse? diagram;
  final bool canCompare;
  final DiagramResponse? baseDiagram;
  final VoidCallback? onCompare;

  const _VersionItem({
    required this.version,
    required this.timeAgo,
    required this.description,
    required this.changes,
    required this.score,
    this.trend,
    this.showLine = true,
    this.diagram,
    this.canCompare = false,
    this.baseDiagram,
    this.onCompare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryPurple, width: 2),
              ),
              child: trend == VersionTrend.down
                  ? const Icon(
                      Icons.arrow_downward,
                      size: 16,
                      color: AppTheme.primaryPurple,
                    )
                  : const Icon(
                      Icons.arrow_upward,
                      size: 16,
                      color: AppTheme.primaryPurple,
                    ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 60,
                color: AppTheme.borderColor,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Version info
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: showLine ? 20 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      version,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      changes,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Text(' • ',
                        style: TextStyle(color: AppTheme.textSecondary)),
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (canCompare && onCompare != null) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: onCompare,
                        icon: const Icon(Icons.compare_arrows, size: 16),
                        label: const Text('Compare'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
