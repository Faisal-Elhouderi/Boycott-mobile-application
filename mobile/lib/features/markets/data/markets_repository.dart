import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/market.dart';

final marketsRepositoryProvider = Provider<MarketsRepository>((ref) {
  return MarketsRepository(apiClient: ref.read(apiClientProvider));
});

final marketsSearchProvider = StateProvider<String>((ref) => '');

final marketsProvider = FutureProvider.autoDispose<List<Market>>((ref) async {
  final repository = ref.read(marketsRepositoryProvider);
  final search = ref.watch(marketsSearchProvider);
  return repository.fetchMarkets(search: search);
});

class MarketsRepository {
  final ApiClient apiClient;

  MarketsRepository({required this.apiClient});

  Future<List<Market>> fetchMarkets({String? search, String? city}) async {
    final response = await apiClient.getMarkets(search: search, city: city);
    final listPayload = unwrapSuccessList(response.data);
    return listPayload
        .whereType<Map>()
        .map((entry) => Market.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }
}
