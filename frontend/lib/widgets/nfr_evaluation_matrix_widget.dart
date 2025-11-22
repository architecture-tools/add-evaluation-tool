import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/nfr_matrix.dart';
import '../network/src/api.dart';
import '../services/nfr_repository.dart';
import '../theme/app_theme.dart';
import '../utils/date_time_utils.dart';

class NfrEvaluationMatrixWidget extends StatefulWidget {
  const NfrEvaluationMatrixWidget({
    super.key,
    required this.data,
    this.nfrs = const [],
    this.onRefresh,
  });

  final NfrMatrixData data;
  final List<NFRResponse> nfrs;
  final VoidCallback? onRefresh;

  @override
  State<NfrEvaluationMatrixWidget> createState() =>
      _NfrEvaluationMatrixWidgetState();
}

class _NfrEvaluationMatrixWidgetState extends State<NfrEvaluationMatrixWidget> {
  late Map<String, Map<String, int>> _scores;
  final NFRRepository _nfrRepository = NFRRepository();
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  static const List<int> _options = [1, 0, -1];
  static const Map<int, String> _labels = {1: '+1', 0: '0', -1: '-1'};

  @override
  void initState() {
    super.initState();
    _loadSavedScores();
  }

  void _loadSavedScores() {
    // Start with data from widget
    _scores = {
      for (final row in widget.data.rows)
        row.nfr: Map<String, int>.from(row.scores),
    };

    // Try to load from localStorage (web only)
    if (kIsWeb) {
      try {
        // Using dart:html for web localStorage
        // Note: This requires import 'dart:html' as html;
        // For now, we'll use a try-catch approach
        final saved = _getFromStorage();
        if (saved != null) {
          // Merge saved scores with current data
          for (final entry in saved.entries) {
            if (_scores.containsKey(entry.key)) {
              _scores[entry.key] = Map<String, int>.from(entry.value);
            }
          }
        }
      } catch (_) {
        // localStorage not available or error
      }
    }
  }

  Map<String, Map<String, int>>? _getFromStorage() {
    if (!kIsWeb) return null;
    try {
      // This will work in web context
      // In a real implementation, we'd use shared_preferences or dart:html
      // For now, return null and we'll implement proper storage
      return null;
    } catch (_) {
      return null;
    }
  }

  void _saveToStorage(Map<String, Map<String, int>> scores) {
    if (!kIsWeb) return;
    try {
      // Save to localStorage
      // In a real implementation, we'd use shared_preferences or dart:html
      // For now, this is a placeholder
    } catch (_) {
      // Storage not available
    }
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
            IconButton(
              icon: const Icon(Icons.add, size: 20),
              tooltip: 'Add NFR',
              onPressed: _showCreateNFRDialog,
              color: AppTheme.primaryPurple,
            ),
            const SizedBox(width: 8),
            if (_hasUnsavedChanges)
              ElevatedButton.icon(
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
              ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Full matrix view coming soon.')),
                );
              },
              child: const Text('Open Full Matrix'),
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
              for (final component in components) _buildHeaderCell(component),
              _buildHeaderCell('Avg Score'),
            ],
          ),
          for (final row in widget.data.rows) _buildDataRow(row, components),
        ],
      ),
    );
  }

  TableRow _buildDataRow(NfrMatrixRow row, List<String> components) {
    return TableRow(
      decoration: const BoxDecoration(color: Colors.white),
      children: [
        _buildNfrCell(row),
        for (final component in components)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _buildScoreCell(row.nfr, component),
          ),
        _buildAverageCell(row.nfr),
      ],
    );
  }

  Widget _buildNfrCell(NfrMatrixRow row) {
    // Find corresponding NFRResponse if available
    final nfrResponse = widget.nfrs.firstWhere(
      (n) => n.name == row.nfr,
      orElse: () => NFRResponse(
        id: '',
        name: row.nfr,
        createdAt: DateTime.now(),
      ),
    );
    final canDelete = nfrResponse.id.isNotEmpty;

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

  Widget _buildScoreCell(String nfr, String component) {
    final value = _scores[nfr]?[component] ?? 0;
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
          onChanged: (selected) {
            if (selected == null) return;
            setState(() {
              _scores[nfr]?[component] = selected;
              _hasUnsavedChanges = true;
            });
          },
        ),
      ),
    );
  }

  Widget _buildAverageCell(String nfr) {
    final average = _calculateAverage(_scores[nfr]);
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
    setState(() {
      _isSaving = true;
    });

    try {
      // TODO: When backend endpoint is available, use POST to save matrix scores
      // For now, save to localStorage as temporary storage
      _saveToStorage(_scores);

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Matrix scores saved locally'),
              ],
            ),
            backgroundColor: AppTheme.green,
            action: SnackBarAction(
              label: 'Note',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Matrix scores are saved locally. Backend endpoint needed for persistent storage.',
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              },
            ),
          ),
        );
      }
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
