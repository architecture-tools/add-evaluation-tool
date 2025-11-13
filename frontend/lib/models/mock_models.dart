import 'package:flutter/material.dart';

class NFRMetric {
  final String name;
  final double score;
  final Color color;

  NFRMetric(this.name, this.score, this.color);
}

enum VersionTrend { up, down, neutral }

class VersionInfo {
  final String version;
  final String timeAgo;
  final String description;
  final String changes;
  final double score;
  final VersionTrend? trend;

  VersionInfo({
    required this.version,
    required this.timeAgo,
    required this.description,
    required this.changes,
    required this.score,
    this.trend,
  });
}

