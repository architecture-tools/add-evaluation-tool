import '../network/src/api.dart';
import 'api_config.dart';

class NFRRepository {
  NFRRepository({NfrApi? api}) : _api = api ?? ApiConfig.nfrApi();

  final NfrApi _api;

  /// Fetch all non-functional requirements
  Future<List<NFRResponse>> fetchNFRs() async {
    final nfrs = await _api.listNfrsApiV1NfrsGet();
    if (nfrs == null) {
      return [];
    }
    // Sort by creation date, newest first
    nfrs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return nfrs;
  }

  /// Create a new non-functional requirement
  Future<NFRResponse> createNFR({
    required String name,
    String? description,
  }) async {
    final request = CreateNFRRequest(
      name: name,
      description: description,
    );

    final response = await _api.createNfrApiV1NfrsPost(request);

    if (response == null) {
      throw Exception('Failed to create NFR: empty response');
    }

    return response;
  }

  /// Delete a non-functional requirement
  Future<void> deleteNFR(String nfrId) async {
    await _api.deleteNfrApiV1NfrsNfrIdDelete(nfrId);
  }
}
