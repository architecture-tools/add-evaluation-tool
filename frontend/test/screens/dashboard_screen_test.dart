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
  group('DashboardScreen Widget Tests', () {
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

    testWidgets('displays loading indicator initially', (tester) async {
      when(() => mockDiagramRepo.fetchDiagrams())
          .thenAnswer((_) async => TestHelpers.createMockDiagrams());
      when(() => mockNfrRepo.fetchNFRs()).thenAnswer((_) async => [
            NFRResponse(
              id: 'nfr-1',
              name: 'Performance',
              createdAt: DateTime.now(),
            ),
          ]);
      when(() => mockMatrixRepo.fetchMatrix(any()))
          .thenAnswer((_) async => null);
      when(() => mockDiagramRepo.parseDiagram(any()))
          .thenAnswer((_) async => TestHelpers.createMockParseResponse());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardScreen(
              onUpload: (context) async {},
              dashboardService: dashboardService,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
