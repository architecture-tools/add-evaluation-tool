import 'package:collection/collection.dart';

import '../models/mock_models.dart';
import '../models/nfr_matrix.dart';
import '../network/src/api.dart';
import '../utils/date_time_utils.dart';
import 'diagram_repository.dart';
import 'mock_data_service.dart';

class DashboardService {
  DashboardService({DiagramRepository? diagramRepository})
      : _diagramRepository = diagramRepository ?? DiagramRepository();

  final DiagramRepository _diagramRepository;

  Future<DashboardViewData> loadDashboard() async {
    final diagrams = await _diagramRepository.fetchDiagrams();
    final metrics = DashboardMetrics.fromDiagrams(diagrams);
    final timeline = _buildTimeline(diagrams);
    final matrix = MockDataService.getDefaultMatrix();

    return DashboardViewData(
      diagrams: diagrams,
      metrics: metrics,
      timeline: timeline,
      nfrMetrics: MockDataService.getNFRMetrics(),
      matrix: matrix,
      fetchedAt: DateTime.now(),
    );
  }

  Future<void> reprocessDiagram(String diagramId) {
    return _diagramRepository.parseDiagram(diagramId);
  }

  List<VersionInfo> _buildTimeline(List<DiagramResponse> diagrams) {
    return diagrams
        .mapIndexed((index, diagram) {
          final trend = _deriveTrend(diagram.status);
          final score = _deriveScore(diagram.status);
          final statusLabel = _statusLabel(diagram.status);
          final description = diagram.sourceUrl.isNotEmpty
              ? diagram.sourceUrl
              : 'Uploaded diagram';

          return VersionInfo(
            version: diagram.name,
            timeAgo: formatRelativeTime(diagram.uploadedAt),
            description: description,
            changes: statusLabel,
            score: score,
            trend: trend,
          );
        })
        .take(6)
        .toList(growable: false);
  }

  VersionTrend? _deriveTrend(DiagramStatus status) {
    switch (status) {
      case DiagramStatus.parsed:
      case DiagramStatus.analysisReady:
        return VersionTrend.up;
      case DiagramStatus.failed:
        return VersionTrend.down;
      case DiagramStatus.uploaded:
        return VersionTrend.neutral;
    }
    return VersionTrend.neutral;
  }

  double _deriveScore(DiagramStatus status) {
    switch (status) {
      case DiagramStatus.analysisReady:
        return 8.8;
      case DiagramStatus.parsed:
        return 7.5;
      case DiagramStatus.uploaded:
        return 6.2;
      case DiagramStatus.failed:
        return 3.5;
    }
    return 6.0;
  }

  String _statusLabel(DiagramStatus status) {
    switch (status) {
      case DiagramStatus.analysisReady:
        return 'Analysis ready';
      case DiagramStatus.parsed:
        return 'Parsed successfully';
      case DiagramStatus.uploaded:
        return 'Awaiting parsing';
      case DiagramStatus.failed:
        return 'Failed';
    }
    return 'Unknown';
  }
}

class DashboardViewData {
  DashboardViewData({
    required this.diagrams,
    required this.metrics,
    required this.timeline,
    required this.nfrMetrics,
    required this.matrix,
    required this.fetchedAt,
  });

  final List<DiagramResponse> diagrams;
  final DashboardMetrics metrics;
  final List<VersionInfo> timeline;
  final List<NFRMetric> nfrMetrics;
  final NfrMatrixData matrix;
  final DateTime fetchedAt;
}

class DashboardMetrics {
  DashboardMetrics({
    required this.totalDiagrams,
    required this.parsedCount,
    required this.pendingCount,
    required this.failedCount,
    required this.lastUploadAt,
  });

  final int totalDiagrams;
  final int parsedCount;
  final int pendingCount;
  final int failedCount;
  final DateTime? lastUploadAt;

  factory DashboardMetrics.fromDiagrams(List<DiagramResponse> diagrams) {
    final parsed = diagrams.where((d) =>
        d.status == DiagramStatus.parsed || d.status == DiagramStatus.analysisReady).length;
    final failed = diagrams.where((d) => d.status == DiagramStatus.failed).length;
    final pending = diagrams.where((d) => d.status == DiagramStatus.uploaded).length;
    final lastUpload = diagrams.isNotEmpty ? diagrams.first.uploadedAt : null;

    return DashboardMetrics(
      totalDiagrams: diagrams.length,
      parsedCount: parsed,
      pendingCount: pending,
      failedCount: failed,
      lastUploadAt: lastUpload,
    );
  }
}
