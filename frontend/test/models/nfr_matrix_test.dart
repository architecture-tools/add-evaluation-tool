import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/models/nfr_matrix.dart';
import 'package:flutter/material.dart';

void main() {
  group('ComponentColumn Tests', () {
    test('creates ComponentColumn with id and label', () {
      const column = ComponentColumn(
        id: 'comp-1',
        label: 'Component 1',
      );

      expect(column.id, equals('comp-1'));
      expect(column.label, equals('Component 1'));
    });
  });

  group('NfrMatrixData Tests', () {
    test('creates NfrMatrixData with required fields', () {
      final data = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [],
        rows: [],
      );

      expect(data.diagramId, equals('diagram-1'));
      expect(data.version, equals('1.0'));
      expect(data.components, isEmpty);
      expect(data.rows, isEmpty);
      expect(data.isPersistent, isTrue);
    });

    test('canPersistChanges returns true when all conditions met', () {
      final data = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [ComponentColumn(id: 'comp-1', label: 'Comp 1')],
        rows: [
          NfrMatrixRow(
            nfrId: 'nfr-1',
            nfr: 'NFR 1',
            color: Colors.blue,
            scores: {'comp-1': 0},
          ),
        ],
      );

      expect(data.canPersistChanges, isTrue);
    });

    test('canPersistChanges returns false when diagramId is empty', () {
      final data = NfrMatrixData(
        diagramId: '',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [],
        rows: [],
      );

      expect(data.canPersistChanges, isFalse);
    });

    test('canPersistChanges returns false when not persistent', () {
      final data = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [],
        rows: [],
        isPersistent: false,
      );

      expect(data.canPersistChanges, isFalse);
    });

    test('canPersistChanges returns false when row has empty nfrId', () {
      final data = NfrMatrixData(
        diagramId: 'diagram-1',
        version: '1.0',
        lastUpdated: DateTime.now(),
        components: const [],
        rows: [
          NfrMatrixRow(
            nfrId: '',
            nfr: 'NFR 1',
            color: Colors.blue,
            scores: {},
          ),
        ],
      );

      expect(data.canPersistChanges, isFalse);
    });
  });

  group('NfrMatrixRow Tests', () {
    test('creates NfrMatrixRow with required fields', () {
      final row = NfrMatrixRow(
        nfrId: 'nfr-1',
        nfr: 'Performance',
        color: Colors.blue,
        scores: {'comp-1': 1, 'comp-2': -1},
      );

      expect(row.nfrId, equals('nfr-1'));
      expect(row.nfr, equals('Performance'));
      expect(row.color, equals(Colors.blue));
      expect(row.scores, equals({'comp-1': 1, 'comp-2': -1}));
    });

    test('scores are copied from input map', () {
      final inputScores = {'comp-1': 1};
      final row = NfrMatrixRow(
        nfrId: 'nfr-1',
        nfr: 'NFR',
        color: Colors.blue,
        scores: inputScores,
      );

      // Modify original map
      inputScores['comp-1'] = 2;

      // Row scores should not change
      expect(row.scores['comp-1'], equals(1));
    });
  });
}

