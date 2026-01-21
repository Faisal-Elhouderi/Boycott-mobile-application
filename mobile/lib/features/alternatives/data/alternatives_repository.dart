import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/alternative.dart';

final alternativesRepositoryProvider = Provider<AlternativesRepository>((ref) {
  return AlternativesRepository(apiClient: ref.read(apiClientProvider));
});

final alternativesSearchProvider = StateProvider<String>((ref) => '');

final alternativesProvider = FutureProvider.autoDispose<List<AlternativeSummary>>((ref) async {
  final repository = ref.read(alternativesRepositoryProvider);
  final search = ref.watch(alternativesSearchProvider);
  return repository.fetchAlternatives(search: search);
});

final alternativeDetailProvider = FutureProvider.autoDispose.family<AlternativeDetail, String>((ref, id) async {
  final repository = ref.read(alternativesRepositoryProvider);
  return repository.fetchAlternativeDetail(id);
});

class AlternativesRepository {
  final ApiClient apiClient;

  AlternativesRepository({required this.apiClient});

  Future<List<AlternativeSummary>> fetchAlternatives({String? search}) async {
    final response = await apiClient.getAlternatives(search: search);
    final listPayload = unwrapSuccessList(response.data);
    return listPayload
        .whereType<Map>()
        .map((entry) =>
            AlternativeSummary.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  Future<AlternativeDetail> fetchAlternativeDetail(String id) async {
    final response = await apiClient.getAlternativeById(id);
    final mapPayload = unwrapSuccessMap(response.data);
    return AlternativeDetail.fromJson(mapPayload);
  }
}
