import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../network/src/api.dart';
import 'api_config.dart';

class DiagramRepository {
  DiagramRepository({DiagramsApi? api}) : _api = api ?? ApiConfig.diagramsApi();

  final DiagramsApi _api;

  Future<List<DiagramResponse>> fetchDiagrams() async {
    final diagrams = await _api.listDiagramsApiV1DiagramsGet();
    if (diagrams == null) {
      return [];
    }
    diagrams.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return diagrams;
  }

  Future<DiagramResponse> uploadDiagram({
    required Uint8List bytes,
    required String filename,
    String? displayName,
  }) async {
    final multipart = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: filename,
      contentType: MediaType('text', 'plain'),
    );

    final response = await _api.uploadDiagramApiV1DiagramsPost(
      multipart,
      name: displayName,
    );

    if (response == null) {
      throw Exception('Upload failed: empty response');
    }

    return response;
  }

  Future<ParseDiagramResponse?> parseDiagram(String diagramId) {
    return _api.parseDiagramApiV1DiagramsDiagramIdParsePost(diagramId);
  }

  Future<DiagramResponse?> getDiagram(String diagramId) {
    return _api.getDiagramApiV1DiagramsDiagramIdGet(diagramId);
  }
}
