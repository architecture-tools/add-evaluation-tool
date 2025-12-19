import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../models/mock_models.dart';
import '../models/nfr_matrix.dart';
import '../network/src/api.dart';
import '../utils/date_time_utils.dart';
import 'diagram_repository.dart';
import 'matrix_repository.dart';
import 'nfr_repository.dart';

class DashboardService {
  DashboardService({
    DiagramRepository? diagramRepository,
    NFRRepository? nfrRepository,
    MatrixRepository? matrixRepository,
  })  : _diagramRepository = diagramRepository ?? DiagramRepository(),
        _nfrRepository = nfrRepository ?? NFRRepository(),
        _matrixRepository = matrixRepository ?? MatrixRepository();

  final DiagramRepository _diagramRepository;
  final NFRRepository _nfrRepository;
  final MatrixRepository _matrixRepository;

  DiagramRepository get diagramRepository => _diagramRepository;

  Future<DashboardViewData> loadDashboard() async {
    List<DiagramResponse> diagrams = [];
    List<NFRResponse> nfrs = [];

    try {
      diagrams = await _diagramRepository.fetchDiagrams();
    } catch (error) {
      debugPrint('Failed to load diagrams: $error');
    }

    try {
      nfrs = await _nfrRepository.fetchNFRs();
    } catch (error) {
      debugPrint('Failed to load NFRs: $error');
    }

    final selectedDiagram = _selectDiagramForMatrix(diagrams);
    DiagramMatrixResponse? matrixResponse;
    ParseDiagramResponse? parseResponse;

    // Fetch matrices for all diagrams to calculate their scores
    final Map<String, double> diagramScores = {};
    for (final diagram in diagrams) {
      // Only fetch matrix for diagrams that are parsed or analysis ready
      if (diagram.status == DiagramStatus.parsed ||
          diagram.status == DiagramStatus.analysisReady) {
        try {
          final matrix = await _matrixRepository.fetchMatrix(diagram.id);
          final score = _scoreFromMatrix(matrix);
          if (score != null) {
            diagramScores[diagram.id] = score;
          }
        } catch (_) {
          // Non-fatal: continue with other diagrams
        }
      }
    }

    if (selectedDiagram != null) {
      try {
        matrixResponse =
            await _matrixRepository.fetchMatrix(selectedDiagram.id);
      } catch (_) {
        // Fallback handled below; surfaced in UI via mock data.
      }

      if (_shouldFetchComponents(selectedDiagram)) {
        try {
          parseResponse =
              await _diagramRepository.parseDiagram(selectedDiagram.id);
        } catch (_) {
          // Non-fatal: we can still show IDs as labels.
        }
      }
    }

    final matrix = _buildMatrixFromData(
      nfrs,
      matrixResponse,
      parseResponse,
      selectedDiagram: selectedDiagram,
    );

    // Convert NFRResponse to NFRMetric for display
    final nfrMetrics = _buildNfrMetrics(
      nfrs,
      matrixResponse?.nfrScores,
    );

    final metrics = DashboardMetrics.fromDiagrams(diagrams);
    final timeline = _buildTimeline(
      diagrams,
      diagramScores: diagramScores,
    );

    return DashboardViewData(
      diagrams: diagrams,
      metrics: metrics,
      timeline: timeline,
      nfrMetrics: nfrMetrics,
      matrix: matrix,
      nfrs: nfrs,
      fetchedAt: DateTime.now(),
      selectedDiagram: selectedDiagram,
    );
  }

  NfrMatrixData _buildMatrixFromData(
    List<NFRResponse> nfrs,
    DiagramMatrixResponse? matrixResponse,
    ParseDiagramResponse? parseResponse, {
    DiagramResponse? selectedDiagram,
  }) {
    if (selectedDiagram == null) {
      return _buildEmptyMatrixData(
        diagram: null,
        components: const [],
        nfrs: nfrs,
      );
    }

    final components = _deriveComponentColumns(
      parseResponse,
      matrixResponse,
    );

    if (matrixResponse == null) {
      return _buildEmptyMatrixData(
        diagram: selectedDiagram,
        components: components,
        nfrs: nfrs,
        canPersist: components.isNotEmpty,
      );
    }

    final entriesByNfr = <String, Map<String, ImpactValue>>{};
    for (final entry in matrixResponse.entries) {
      final row = entriesByNfr.putIfAbsent(entry.nfrId, () => {});
      row[entry.componentId] = entry.impact;
    }

    final nfrById = {for (final nfr in nfrs) nfr.id: nfr};
    final nfrIds =
        {...nfrById.keys, ...entriesByNfr.keys}.toList(growable: false)
          ..sort((a, b) {
            final aName = nfrById[a]?.name ?? a;
            final bName = nfrById[b]?.name ?? b;
            return aName.compareTo(bName);
          });

    if (components.isEmpty || nfrIds.isEmpty) {
      return _buildEmptyMatrixData(
        diagram: selectedDiagram,
        components: components,
        nfrs: nfrs,
        canPersist: components.isNotEmpty,
      );
    }

    final rows = nfrIds.map((nfrId) {
      final nfr = nfrById[nfrId];
      final label = nfr?.name ?? 'NFR ${_shortId(nfrId)}';
      final componentScores = <String, int>{
        for (final component in components)
          component.id: _scoreFromImpact(
            entriesByNfr[nfrId]?[component.id],
          ),
      };

      return NfrMatrixRow(
        nfrId: nfrId,
        nfr: label,
        color: _getNFRColor(label),
        scores: componentScores,
      );
    }).toList();

    return NfrMatrixData(
      diagramId: selectedDiagram.id,
      version: selectedDiagram.name,
      lastUpdated: selectedDiagram.parsedAt ?? selectedDiagram.uploadedAt,
      components: components,
      rows: rows,
      sourceUrl: selectedDiagram.sourceUrl,
      isPersistent: true,
    );
  }

  List<ComponentColumn> _deriveComponentColumns(
    ParseDiagramResponse? parseResponse,
    DiagramMatrixResponse? matrixResponse,
  ) {
    final componentNames = <String, String>{};

    if (parseResponse != null) {
      for (final component in parseResponse.components) {
        componentNames[component.id] = component.name;
      }
    }

    if (matrixResponse != null) {
      for (final entry in matrixResponse.entries) {
        componentNames.putIfAbsent(
          entry.componentId,
          () => 'Component ${_shortId(entry.componentId)}',
        );
      }
    }

    return componentNames.entries
        .map((entry) =>
            ComponentColumn(id: entry.key, label: entry.value.trim()))
        .toList()
      ..sort((a, b) => a.label.compareTo(b.label));
  }

  NfrMatrixData _buildEmptyMatrixData({
    required DiagramResponse? diagram,
    required List<ComponentColumn> components,
    required List<NFRResponse> nfrs,
    bool canPersist = false,
  }) {
    final rows = nfrs.map((nfr) {
      final zeroScores = <String, int>{
        for (final component in components) component.id: 0,
      };
      return NfrMatrixRow(
        nfrId: nfr.id,
        nfr: nfr.name,
        color: _getNFRColor(nfr.name),
        scores: zeroScores,
      );
    }).toList();

    final timestamp =
        diagram?.parsedAt ?? diagram?.uploadedAt ?? DateTime.now();

    return NfrMatrixData(
      diagramId: diagram?.id ?? '',
      version: diagram?.name ?? 'No diagrams available',
      lastUpdated: timestamp,
      components: components,
      rows: rows,
      sourceUrl: diagram?.sourceUrl,
      isPersistent: canPersist,
    );
  }

  List<NFRMetric> _buildNfrMetrics(
    List<NFRResponse> nfrs,
    List<NFRScoreResponse>? scores,
  ) {
    if (scores == null || scores.isEmpty) {
      return [];
    }

    final nfrById = {for (final nfr in nfrs) nfr.id: nfr};
    return scores.map((score) {
      final nfr = nfrById[score.nfrId];
      final label = nfr?.name ?? 'NFR ${_shortId(score.nfrId)}';
      return NFRMetric(
        label,
        score.score.toDouble(),
        _getNFRColor(label),
      );
    }).toList();
  }

  DiagramResponse? _selectDiagramForMatrix(List<DiagramResponse> diagrams) {
    if (diagrams.isEmpty) {
      return null;
    }

    return diagrams.firstWhere(
      (diagram) =>
          diagram.status == DiagramStatus.analysisReady ||
          diagram.status == DiagramStatus.parsed,
      orElse: () => diagrams.first,
    );
  }

  bool _shouldFetchComponents(DiagramResponse diagram) {
    return diagram.status == DiagramStatus.parsed ||
        diagram.status == DiagramStatus.analysisReady;
  }

  int _scoreFromImpact(ImpactValue? impact) {
    switch (impact) {
      case ImpactValue.POSITIVE:
        return 1;
      case ImpactValue.NEGATIVE:
        return -1;
      case ImpactValue.NO_EFFECT:
      default:
        return 0;
    }
  }

  String _shortId(String id) {
    if (id.length <= 8) {
      return id;
    }
    return id.substring(0, 8);
  }

  Color _getNFRColor(String name) {
    // Assign colors based on NFR name
    final lowerName = name.toLowerCase();
    if (lowerName.contains('performance') || lowerName.contains('speed')) {
      return const Color(0xFF3B82F6); // Blue
    } else if (lowerName.contains('security')) {
      return const Color(0xFFEF4444); // Red
    } else if (lowerName.contains('scalability') ||
        lowerName.contains('scale')) {
      return const Color(0xFF10B981); // Green
    } else if (lowerName.contains('availability') ||
        lowerName.contains('reliability')) {
      return const Color(0xFFF59E0B); // Yellow
    } else {
      return const Color(0xFF7C3AED); // Purple (default)
    }
  }

  Future<void> reprocessDiagram(String diagramId) {
    return _diagramRepository.parseDiagram(diagramId);
  }

  List<VersionInfo> _buildTimeline(
    List<DiagramResponse> diagrams, {
    Map<String, double>? diagramScores,
  }) {
    return diagrams
        .mapIndexed((index, diagram) {
          final trend = _deriveTrend(diagram.status);
          // Use actual score from diagramScores map if available
          final score = diagramScores?[diagram.id] ?? 0.0;
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

  double? _scoreFromMatrix(DiagramMatrixResponse? matrix) {
    if (matrix == null) {
      return null;
    }

    if (matrix.overallScore != null) {
      return double.parse(matrix.overallScore!.toStringAsFixed(1));
    }

    if (matrix.entries.isEmpty) {
      return null;
    }

    final total = matrix.entries.fold<int>(0, (sum, entry) {
      switch (entry.impact) {
        case ImpactValue.POSITIVE:
          return sum + 1;
        case ImpactValue.NEGATIVE:
          return sum - 1;
        case ImpactValue.NO_EFFECT:
        default:
          return sum;
      }
    });

    final average = total / matrix.entries.length;
    return double.parse(average.toStringAsFixed(1));
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
    this.selectedDiagram,
  });

  final List<DiagramResponse> diagrams;
  final DashboardMetrics metrics;
  final List<VersionInfo> timeline;
  final List<NFRMetric> nfrMetrics;
  final NfrMatrixData matrix;
  final List<NFRResponse> nfrs;
  final DateTime fetchedAt;
  final DiagramResponse? selectedDiagram;
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
