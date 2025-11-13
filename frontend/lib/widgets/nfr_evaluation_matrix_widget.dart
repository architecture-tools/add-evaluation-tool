import 'package:flutter/material.dart';

import '../models/nfr_matrix.dart';
import '../theme/app_theme.dart';
import '../utils/date_time_utils.dart';

class NfrEvaluationMatrixWidget extends StatefulWidget {
  const NfrEvaluationMatrixWidget({super.key, required this.data});

  final NfrMatrixData data;

  @override
  State<NfrEvaluationMatrixWidget> createState() => _NfrEvaluationMatrixWidgetState();
}

class _NfrEvaluationMatrixWidgetState extends State<NfrEvaluationMatrixWidget> {
  late Map<String, Map<String, int>> _scores;

  static const List<int> _options = [1, 0, -1];
  static const Map<int, String> _labels = {1: '+1', 0: '0', -1: '-1'};

  @override
  void initState() {
    super.initState();
    _scores = {
      for (final row in widget.data.rows)
        row.nfr: Map<String, int>.from(row.scores),
    };
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
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Last updated: ${formatRelativeTime(widget.data.lastUpdated)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
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
        FilledButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Full matrix view coming soon.')),
            );
          },
          child: const Text('Open Full Matrix'),
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
        border: TableBorder(horizontalInside: BorderSide(color: AppTheme.borderColor)),
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
                        color: option == value ? textColor : AppTheme.textPrimary,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (selected) {
            if (selected == null) return;
            setState(() {
              _scores[nfr]?[component] = selected;
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
