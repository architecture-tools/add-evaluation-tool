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
  }) {
    final request = UpdateMatrixCellRequest(
      nfrId: nfrId,
      componentId: componentId,
      impact: impact,
    );

    return _api.updateMatrixCellApiV1DiagramsDiagramIdMatrixPut(
      diagramId,
      request,
    );
  }
}
