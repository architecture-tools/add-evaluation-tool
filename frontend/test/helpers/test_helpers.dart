import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';

/// Helper functions for creating test data
class TestHelpers {
  /// Creates a mock DiagramResponse for testing
  static DiagramResponse createMockDiagram({
    String? id,
    String? name,
    DiagramStatus? status,
    DateTime? uploadedAt,
    String? sourceUrl = '',
  }) {
    return DiagramResponse(
      id: id ?? 'test-diagram-1',
      name: name ?? 'Test Diagram',
      status: status ?? DiagramStatus.parsed,
      uploadedAt: uploadedAt ?? DateTime.now(),
      sourceUrl: sourceUrl ?? '',
    );
  }

  /// Creates a list of mock diagrams with different statuses
  static List<DiagramResponse> createMockDiagrams() {
    final now = DateTime.now();
    return [
      createMockDiagram(
        id: 'diagram-1',
        name: 'Diagram 1',
        status: DiagramStatus.parsed,
        uploadedAt: now.subtract(const Duration(hours: 2)),
      ),
      createMockDiagram(
        id: 'diagram-2',
        name: 'Diagram 2',
        status: DiagramStatus.analysisReady,
        uploadedAt: now.subtract(const Duration(hours: 1)),
      ),
      createMockDiagram(
        id: 'diagram-3',
        name: 'Diagram 3',
        status: DiagramStatus.uploaded,
        uploadedAt: now.subtract(const Duration(minutes: 30)),
      ),
      createMockDiagram(
        id: 'diagram-4',
        name: 'Diagram 4',
        status: DiagramStatus.failed,
        uploadedAt: now.subtract(const Duration(minutes: 15)),
      ),
    ];
  }

  /// Creates a mock ParseDiagramResponse
  static ParseDiagramResponse createMockParseResponse({
    String? diagramId,
    DiagramStatus? status,
  }) {
    return ParseDiagramResponse(
      diagram: createMockDiagram(
        id: diagramId ?? 'test-diagram-1',
        status: status ?? DiagramStatus.parsed,
      ),
      components: [],
      relationships: [],
    );
  }
}

/// Widget test helper to find widgets by type or key
extension WidgetTestHelpers on WidgetTester {
  /// Finds a widget by its type
  T findWidgetByType<T extends Widget>() {
    return find.byType(T).evaluate().first.widget as T;
  }

  /// Finds a widget by its key
  T findWidgetByKey<T extends Widget>(Key key) {
    return find.byKey(key).evaluate().first.widget as T;
  }

  /// Waits for async operations to complete
  Future<void> waitForAsync() async {
    await pumpAndSettle();
  }
}
