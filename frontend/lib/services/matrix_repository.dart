import '../network/src/api.dart';
import 'api_config.dart';

/// Repository responsible for interacting with the diagram matrix endpoints.
class MatrixRepository {
  MatrixRepository({DiagramsApi? api}) : _api = api ?? ApiConfig.diagramsApi();

  final DiagramsApi _api;

  Future<DiagramMatrixResponse?> fetchMatrix(String diagramId) {
    return _api.getMatrixApiV1DiagramsDiagramIdMatrixGet(diagramId);
  }

  Future<MatrixCellUpdateResponse?> updateCell({
    required String diagramId,
    required String nfrId,
    required String componentId,
    required ImpactValue impact,
  }) async {
    try {
      final request = UpdateMatrixCellRequest(
        nfrId: nfrId,
        componentId: componentId,
        impact: impact,
      );

      final response =
          await _api.updateMatrixCellApiV1DiagramsDiagramIdMatrixPut(
        diagramId,
        request,
      );

      if (response == null) {
        throw Exception('Received null response from server');
      }

      return response;
    } catch (e) {
      // Re-throw with more context
      throw Exception('Failed to update matrix cell: $e');
    }
  }
}
