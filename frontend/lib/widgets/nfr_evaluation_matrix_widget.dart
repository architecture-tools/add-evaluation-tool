import 'package:flutter/material.dart';

import '../models/nfr_matrix.dart';
import '../network/src/api.dart';
import '../services/nfr_repository.dart';
import '../services/matrix_repository.dart';
import '../services/diagram_repository.dart';
import '../theme/app_theme.dart';
import '../utils/date_time_utils.dart';
import 'diagram_graph_widget.dart';

class NfrEvaluationMatrixWidget extends StatefulWidget {
  const NfrEvaluationMatrixWidget({
    super.key,
    required this.data,
    this.nfrs = const [],
    this.onRefresh,
    NFRRepository? nfrRepository,
    MatrixRepository? matrixRepository,
    DiagramRepository? diagramRepository,
  })  : _nfrRepository = nfrRepository,
        _matrixRepository = matrixRepository,
        _diagramRepository = diagramRepository;

  final NfrMatrixData data;
  final List<NFRResponse> nfrs;
  final VoidCallback? onRefresh;
  final NFRRepository? _nfrRepository;
  final MatrixRepository? _matrixRepository;
  final DiagramRepository? _diagramRepository;

  @override
  State<NfrEvaluationMatrixWidget> createState() =>
      _NfrEvaluationMatrixWidgetState();
}

class _NfrEvaluationMatrixWidgetState extends State<NfrEvaluationMatrixWidget> {
  late Map<String, Map<String, int>> _scores;
  final Map<String, Map<String, int>> _pendingChanges = {};
  late final NFRRepository _nfrRepository;
  late final MatrixRepository _matrixRepository;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nfrRepository = widget._nfrRepository ?? NFRRepository();
    _matrixRepository = widget._matrixRepository ?? MatrixRepository();
    _initializeScores();
  }

  static const List<int> _options = [1, 0, -1];
  static const Map<int, String> _labels = {1: '+1', 0: '0', -1: '-1'};

  @override
  void didUpdateWidget(covariant NfrEvaluationMatrixWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.diagramId != widget.data.diagramId ||
        oldWidget.data.lastUpdated != widget.data.lastUpdated) {
      _initializeScores();
    }
  }

  void _initializeScores() {
    _scores = {
      for (final row in widget.data.rows)
        _rowKey(row): _normalizeScores(row.scores),
    };
    _pendingChanges.clear();
    _hasUnsavedChanges = false;
  }

  Map<String, int> _normalizeScores(Map<String, int> rawScores) {
    final normalized = Map<String, int>.from(rawScores);
    for (final component in widget.data.components) {
      normalized.putIfAbsent(component.id, () => 0);
    }
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildLegend(),
            const SizedBox(height: 24),
            _buildTable(context),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_hasUnsavedChanges)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.yellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.yellow),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, size: 14, color: AppTheme.yellow),
                        const SizedBox(width: 6),
                        Text(
                          'Unsaved changes',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.yellow,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  'Last updated: ${formatRelativeTime(widget.data.lastUpdated)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NFR Evaluation Matrix - ${widget.data.version}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Adjust component impact using +1 / 0 / -1 scoring.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (widget.data.diagramId.isNotEmpty &&
                widget._diagramRepository != null)
              OutlinedButton.icon(
                onPressed: () => _showGraphDialog(context),
                icon: const Icon(Icons.account_tree, size: 18),
                label: const Text('View Graph'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryPurple,
                  side: const BorderSide(color: AppTheme.primaryPurple),
                ),
              ),
            if (widget.data.diagramId.isNotEmpty &&
                widget._diagramRepository != null)
              const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              tooltip: 'Add NFR',
              onPressed: _showCreateNFRDialog,
              color: AppTheme.primaryPurple,
            ),
            const SizedBox(width: 8),
            if (_hasUnsavedChanges)
              widget.data.canPersistChanges
                  ? ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveMatrix,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save, size: 18),
                      label: Text(_isSaving ? 'Saving...' : 'Save Matrix'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.green,
                        foregroundColor: Colors.white,
                      ),
                    )
                  : Tooltip(
                      message:
                          'Matrix is read-only until a parsed diagram is available.',
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.lock, size: 18),
                        label: const Text('Read-only'),
                      ),
                    ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        _LegendChip(color: Color(0xFFD1FAE5), label: '+1 Positive impact'),
        _LegendChip(color: Color(0xFFE5E7EB), label: '0 Neutral'),
        _LegendChip(color: Color(0xFFFEE2E2), label: '-1 Negative impact'),
      ],
    );
  }

  Widget _buildTable(BuildContext context) {
    final components = widget.data.components;

    if (components.isEmpty || widget.data.rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: const Text(
          'Matrix data will appear once a diagram is parsed and NFRs are defined.',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: {
          0: const FixedColumnWidth(160),
          for (int i = 0; i < components.length; i++)
            i + 1: const FixedColumnWidth(140),
          components.length + 1: const FixedColumnWidth(120),
        },
        border: TableBorder(
            horizontalInside: BorderSide(color: AppTheme.borderColor)),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            decoration: BoxDecoration(color: AppTheme.background),
            children: [
              _buildHeaderCell('NFR'),
              for (final component in components)
                _buildHeaderCell(component.label),
              _buildHeaderCell('Avg Score'),
            ],
          ),
          for (final row in widget.data.rows) _buildDataRow(row, components),
        ],
      ),
    );
  }

  TableRow _buildDataRow(NfrMatrixRow row, List<ComponentColumn> components) {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: [
        _buildNfrCell(row),
        for (final component in components)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _buildScoreCell(row, component),
          ),
        _buildAverageCell(row),
      ],
    );
  }

  Widget _buildNfrCell(NfrMatrixRow row) {
    final matchingNfr = widget.nfrs.where((n) => n.id == row.nfrId).firstOrNull;
    final nfrResponse = matchingNfr ??
        NFRResponse(
          id: row.nfrId,
          name: row.nfr,
          createdAt: DateTime.now(),
        );
    final canDelete = matchingNfr != null && matchingNfr.id.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: row.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              row.nfr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              color: AppTheme.textSecondary,
              onPressed: () => _deleteNFR(nfrResponse.id, nfrResponse.name),
              tooltip: 'Delete NFR',
            ),
        ],
      ),
    );
  }

  Widget _buildScoreCell(NfrMatrixRow row, ComponentColumn component) {
    final rowKey = _rowKey(row);
    final value = _scores[rowKey]?[component.id] ?? 0;
    final background = _backgroundForValue(value);
    final textColor = _textColorForValue(value);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          items: _options
              .map((option) => DropdownMenuItem<int>(
                    value: option,
                    child: Text(
                      _labels[option]!,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:
                            option == value ? textColor : AppTheme.textPrimary,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: _isSaving
              ? null
              : (selected) {
                  if (selected == null) return;
                  setState(() {
                    _scores[rowKey]?[component.id] = selected;
                    if (_shouldTrackChange(row, component)) {
                      final pending =
                          _pendingChanges.putIfAbsent(row.nfrId, () => {});
                      pending[component.id] = selected;
                    }
                    _hasUnsavedChanges = true;
                  });
                },
        ),
      ),
    );
  }

  Widget _buildAverageCell(NfrMatrixRow row) {
    final average = _calculateAverage(_scores[_rowKey(row)]);
    final averageLabel = average.toStringAsFixed(1);
    final color = average > 0.5
        ? AppTheme.green
        : average < -0.5
            ? AppTheme.red
            : AppTheme.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        averageLabel,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.right,
      ),
    );
  }

  Widget _buildHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  double _calculateAverage(Map<String, int>? scores) {
    if (scores == null || scores.isEmpty) {
      return 0;
    }
    final total = scores.values.fold<int>(0, (sum, value) => sum + value);
    return total / scores.length;
  }

  Color _backgroundForValue(int value) {
    switch (value) {
      case 1:
        return const Color(0xFFD1FAE5);
      case -1:
        return const Color(0xFFFEE2E2);
      case 0:
      default:
        return const Color(0xFFE5E7EB);
    }
  }

  Color _textColorForValue(int value) {
    switch (value) {
      case 1:
        return const Color(0xFF047857);
      case -1:
        return const Color(0xFFB91C1C);
      case 0:
      default:
        return AppTheme.textPrimary;
    }
  }

  Future<void> _showCreateNFRDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Non-Functional Requirement'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    hintText: 'e.g., Performance, Security, Scalability',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.length > 255) {
                      return 'Name must be 255 characters or less';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Describe the NFR requirement',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await _nfrRepository.createNFR(
          name: nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'NFR "${nameController.text.trim()}" created successfully'),
              backgroundColor: AppTheme.green,
            ),
          );
          widget.onRefresh?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create NFR: $e'),
              backgroundColor: AppTheme.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteNFR(String nfrId, String nfrName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete NFR'),
        content: Text(
            'Are you sure you want to delete "$nfrName"? This will remove it from the matrix.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _nfrRepository.deleteNFR(nfrId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('NFR "$nfrName" deleted successfully'),
              backgroundColor: AppTheme.green,
            ),
          );
          widget.onRefresh?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete NFR: $e'),
              backgroundColor: AppTheme.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveMatrix() async {
    if (_pendingChanges.isEmpty) {
      setState(() {
        _hasUnsavedChanges = false;
      });
      return;
    }

    if (widget.data.diagramId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Matrix cannot be persisted: missing diagram context'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      for (final entry in _pendingChanges.entries) {
        final nfrId = entry.key;
        for (final componentEntry in entry.value.entries) {
          await _matrixRepository.updateCell(
            diagramId: widget.data.diagramId,
            nfrId: nfrId,
            componentId: componentEntry.key,
            impact: _impactFromScore(componentEntry.value),
          );
        }
      }

      if (!mounted) return;

      final updatedCells = _pendingChangeCount();

      setState(() {
        _pendingChanges.clear();
        _hasUnsavedChanges = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Saved $updatedCells matrix ${updatedCells == 1 ? 'cell' : 'cells'}'),
          backgroundColor: AppTheme.green,
        ),
      );
      widget.onRefresh?.call();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save matrix: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  ImpactValue _impactFromScore(int score) {
    if (score > 0) {
      return ImpactValue.POSITIVE;
    } else if (score < 0) {
      return ImpactValue.NEGATIVE;
    }
    return ImpactValue.NO_EFFECT;
  }

  int _pendingChangeCount() {
    return _pendingChanges.values
        .fold<int>(0, (sum, entry) => sum + entry.length);
  }

  bool _shouldTrackChange(NfrMatrixRow row, ComponentColumn component) {
    return widget.data.canPersistChanges &&
        row.nfrId.isNotEmpty &&
        component.id.isNotEmpty;
  }

  String _rowKey(NfrMatrixRow row) {
    return row.nfrId.isNotEmpty ? row.nfrId : row.nfr;
  }

  Future<void> _showGraphDialog(BuildContext context) async {
    if (widget._diagramRepository == null || widget.data.diagramId.isEmpty) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => _DiagramGraphDialog(
        diagramId: widget.data.diagramId,
        diagramName: widget.data.version,
        diagramRepository: widget._diagramRepository!,
      ),
    );
  }
}

class _DiagramGraphDialog extends StatefulWidget {
  const _DiagramGraphDialog({
    required this.diagramId,
    required this.diagramName,
    required this.diagramRepository,
  });

  final String diagramId;
  final String diagramName;
  final DiagramRepository diagramRepository;

  @override
  State<_DiagramGraphDialog> createState() => _DiagramGraphDialogState();
}

class _DiagramGraphDialogState extends State<_DiagramGraphDialog> {
  ParseDiagramResponse? _parsedDiagram;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDiagramGraph();
  }

  Future<void> _loadDiagramGraph() async {
    try {
      final parsed =
          await widget.diagramRepository.parseDiagram(widget.diagramId);
      if (mounted) {
        setState(() {
          _parsedDiagram = parsed;
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
        constraints: const BoxConstraints(maxWidth: 1400, maxHeight: 900),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.diagramName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Diagram Structure',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
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
                                'Failed to load diagram graph',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : _parsedDiagram != null
                          ? Padding(
                              padding: const EdgeInsets.all(16),
                              child: DiagramGraphWidget(
                                components: _parsedDiagram!.components,
                                relationships: _parsedDiagram!.relationships,
                                height: 700,
                                title: 'Diagram Structure',
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No parsed diagram data available',
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

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
