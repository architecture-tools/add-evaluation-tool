import 'package:flutter/material.dart';

class NfrMatrixData {
  NfrMatrixData({
    required this.version,
    required this.lastUpdated,
    required this.components,
    required this.rows,
  });

  final String version;
  final DateTime lastUpdated;
  final List<String> components;
  final List<NfrMatrixRow> rows;
}

class NfrMatrixRow {
  NfrMatrixRow({
    required this.nfr,
    required this.color,
    required Map<String, int> scores,
  }) : scores = Map<String, int>.from(scores);

  final String nfr;
  final Color color;
  final Map<String, int> scores;
}
