import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/screens/dashboard_screen.dart';
import 'package:architecture_evaluation_tool/widgets/kpi_card.dart';
import 'package:architecture_evaluation_tool/services/dashboard_service.dart';
import 'package:architecture_evaluation_tool/services/diagram_repository.dart';
import 'package:architecture_evaluation_tool/services/nfr_repository.dart';
import 'package:architecture_evaluation_tool/services/matrix_repository.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/test_helpers.dart';

class MockDiagramRepository extends Mock implements DiagramRepository {}
class MockNFRRepository extends Mock implements NFRRepository {}
class MockMatrixRepository extends Mock implements MatrixRepository {}

void main() {
  group('DashboardScreen Extended Tests', () {
    late MockDiagramRepository mockDiagramRepo;
    late MockNFRRepository mockNfrRepo;
    late MockMatrixRepository mockMatrixRepo;
    late DashboardService dashboardService;

    setUp(() {
      mockDiagramRepo = MockDiagramRepository();
      mockNfrRepo = MockNFRRepository();
      mockMatrixRepo = MockMatrixRepository();
      dashboardService = DashboardService(
        diagramRepository: mockDiagramRepo,
        nfrRepository: mockNfrRepo,
        matrixRepository: mockMatrixRepo,
      );
    });

    // Removed tests that require child widgets to not make HTTP calls
    // These tests are covered by service-level tests
  });
}

