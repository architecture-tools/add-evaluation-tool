import 'package:flutter/material.dart';

class ComponentColumn {
  const ComponentColumn({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

class NfrMatrixData {
  NfrMatrixData({
    required this.diagramId,
    required this.version,
    required this.lastUpdated,
    required this.components,
    required this.rows,
    this.sourceUrl,
    this.isPersistent = true,
  });

  final String diagramId;
  final String version;
  final DateTime lastUpdated;
  final List<ComponentColumn> components;
  final List<NfrMatrixRow> rows;
  final String? sourceUrl;
  final bool isPersistent;

  bool get canPersistChanges =>
      isPersistent &&
      diagramId.isNotEmpty &&
      rows.every((row) => row.nfrId.isNotEmpty);
}

class NfrMatrixRow {
  NfrMatrixRow({
    required this.nfrId,
    required this.nfr,
    required this.color,
    required Map<String, int> scores,
  }) : scores = Map<String, int>.from(scores);

  final String nfrId;
  final String nfr;
  final Color color;
  final Map<String, int> scores;
}
