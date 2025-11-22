import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../models/mock_models.dart';
import '../models/nfr_matrix.dart';
import '../network/src/api.dart';
import '../utils/date_time_utils.dart';
import 'diagram_repository.dart';
import 'mock_data_service.dart';
import 'nfr_repository.dart';

class DashboardService {
  DashboardService({
    DiagramRepository? diagramRepository,
    NFRRepository? nfrRepository,
  })  : _diagramRepository = diagramRepository ?? DiagramRepository(),
        _nfrRepository = nfrRepository ?? NFRRepository();

  final DiagramRepository _diagramRepository;
  final NFRRepository _nfrRepository;

  Future<DashboardViewData> loadDashboard() async {
    final diagrams = await _diagramRepository.fetchDiagrams();
    final nfrs = await _nfrRepository.fetchNFRs();
    final metrics = DashboardMetrics.fromDiagrams(diagrams);
    final timeline = _buildTimeline(diagrams);
    
    // Build matrix from real NFRs and components from parsed diagrams
    final matrix = _buildMatrixFromData(nfrs, diagrams);
    
    // Convert NFRResponse to NFRMetric for display
    final nfrMetrics = nfrs.map((nfr) {
      // Use a default score for now (could be calculated from evaluations)
      return NFRMetric(
        nfr.name,
        7.5, // Default score, could be enhanced with actual evaluation data
        _getNFRColor(nfr.name),
      );
    }).toList();

    return DashboardViewData(
      diagrams: diagrams,
      metrics: metrics,
      timeline: timeline,
      nfrMetrics: nfrMetrics.isNotEmpty ? nfrMetrics : MockDataService.getNFRMetrics(),
      matrix: matrix,
      nfrs: nfrs,
      fetchedAt: DateTime.now(),
    );
  }

  NfrMatrixData _buildMatrixFromData(List<NFRResponse> nfrs, List<DiagramResponse> diagrams) {
    // Extract components from parsed diagrams
    final components = <String>{};
    for (final diagram in diagrams) {
      if (diagram.status == DiagramStatus.parsed || 
          diagram.status == DiagramStatus.analysisReady) {
        // For now, use mock components. In the future, fetch from parseDiagram response
        // This would require calling getDiagram or parseDiagram to get components
        components.addAll(['API Gateway', 'Auth Service', 'Payment', 'Order Mgmt', 'Database']);
      }
    }
    
    // If no components found, use default
    final componentList = components.isEmpty 
        ? ['API Gateway', 'Auth Service', 'Payment', 'Order Mgmt', 'Database']
        : components.toList()..sort();

    // Build matrix rows from NFRs
    final rows = nfrs.map((nfr) {
      // Initialize scores with 0 for all components
      final scores = <String, int>{
        for (final component in componentList) component: 0,
      };
      
      return NfrMatrixRow(
        nfr: nfr.name,
        color: _getNFRColor(nfr.name),
        scores: scores,
      );
    }).toList();

    // If no NFRs, use default matrix
    if (rows.isEmpty) {
      return MockDataService.getDefaultMatrix();
    }

    // Get the latest diagram version for matrix version
    final latestDiagram = diagrams.isNotEmpty ? diagrams.first : null;
    final version = latestDiagram?.name ?? 'v2.3.1';

    return NfrMatrixData(
      version: version,
      lastUpdated: DateTime.now(),
      components: componentList,
      rows: rows,
    );
  }

  Color _getNFRColor(String name) {
    // Assign colors based on NFR name
    final lowerName = name.toLowerCase();
    if (lowerName.contains('performance') || lowerName.contains('speed')) {
      return const Color(0xFF3B82F6); // Blue
    } else if (lowerName.contains('security')) {
      return const Color(0xFFEF4444); // Red
    } else if (lowerName.contains('scalability') || lowerName.contains('scale')) {
      return const Color(0xFF10B981); // Green
    } else if (lowerName.contains('availability') || lowerName.contains('reliability')) {
      return const Color(0xFFF59E0B); // Yellow
    } else {
      return const Color(0xFF7C3AED); // Purple (default)
    }
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
    this.nfrs = const [],
  });

  final List<DiagramResponse> diagrams;
  final DashboardMetrics metrics;
  final List<VersionInfo> timeline;
  final List<NFRMetric> nfrMetrics;
  final NfrMatrixData matrix;
  final List<NFRResponse> nfrs;
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
    int parsed = 0;
    int failed = 0;
    int pending = 0;

    for (final diagram in diagrams) {
      final status = diagram.status;
      if (status == DiagramStatus.parsed ||
          status == DiagramStatus.analysisReady) {
        parsed++;
      } else if (status == DiagramStatus.failed) {
        failed++;
      } else if (status == DiagramStatus.uploaded) {
        pending++;
      }
    }

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
