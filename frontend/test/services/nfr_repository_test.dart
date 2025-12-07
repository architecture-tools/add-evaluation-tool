import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/services/nfr_repository.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'nfr_repository_test.mocks.dart';

@GenerateMocks([NfrApi])
void main() {
  group('NFRRepository Tests', () {
    late NFRRepository repository;
    late MockNfrApi mockApi;

    setUp(() {
      mockApi = MockNfrApi();
      repository = NFRRepository(api: mockApi);
    });

    test('fetchNFRs returns sorted list', () async {
      final nfr1 = NFRResponse(
        id: '1',
        name: 'NFR 1',
        createdAt: DateTime(2024, 1, 1),
      );
      final nfr2 = NFRResponse(
        id: '2',
        name: 'NFR 2',
        createdAt: DateTime(2024, 1, 2),
      );

      when(mockApi.listNfrsApiV1NfrsGet())
          .thenAnswer((_) async => [nfr1, nfr2]);

      final result = await repository.fetchNFRs();

      expect(result.length, 2);
      expect(result[0].id, '2'); // Newest first
      expect(result[1].id, '1');
    });

    test('fetchNFRs returns empty list when API returns null', () async {
      when(mockApi.listNfrsApiV1NfrsGet()).thenAnswer((_) async => null);

      final result = await repository.fetchNFRs();

      expect(result, isEmpty);
    });

    test('createNFR returns created NFR', () async {
      final request = CreateNFRRequest(
        name: 'Test NFR',
        description: 'Test description',
      );
      final expectedResponse = NFRResponse(
        id: 'new-id',
        name: 'Test NFR',
        createdAt: DateTime.now(),
      );

      when(mockApi.createNfrApiV1NfrsPost(request))
          .thenAnswer((_) async => expectedResponse);

      final result = await repository.createNFR(
        name: 'Test NFR',
        description: 'Test description',
      );

      expect(result.id, 'new-id');
      expect(result.name, 'Test NFR');
    });

    test('createNFR throws exception when response is null', () async {
      final request = CreateNFRRequest(
        name: 'Test NFR',
        description: 'Test description',
      );

      when(mockApi.createNfrApiV1NfrsPost(request))
          .thenAnswer((_) async => null);

      expect(
        () => repository.createNFR(
          name: 'Test NFR',
          description: 'Test description',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('deleteNFR calls API delete method', () async {
      when(mockApi.deleteNfrApiV1NfrsNfrIdDelete('nfr-id'))
          .thenAnswer((_) async => Future.value());

      await repository.deleteNFR('nfr-id');

      verify(mockApi.deleteNfrApiV1NfrsNfrIdDelete('nfr-id')).called(1);
    });
  });
}
