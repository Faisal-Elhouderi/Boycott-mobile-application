import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/item.dart';

final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepository(apiClient: ref.read(apiClientProvider));
});

final itemsProvider = FutureProvider<List<Item>>((ref) async {
  final repository = ref.read(itemsRepositoryProvider);
  return repository.fetchItems();
});

final itemDetailProvider = FutureProvider.family<Item, String>((ref, id) async {
  final repository = ref.read(itemsRepositoryProvider);
  return repository.fetchItem(id);
});

class ItemsRepository {
  final ApiClient apiClient;

  ItemsRepository({required this.apiClient});

  Future<List<Item>> fetchItems() async {
    final response = await apiClient.getItems();
    final payload = _unwrapData(response.data);
    final listPayload = _unwrapList(payload);
    return listPayload
        .whereType<Map<String, dynamic>>()
        .map((entry) => Item.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  Future<Item> fetchItem(String id) async {
    final response = await apiClient.getItemById(id);
    final payload = _unwrapData(response.data);
    final itemPayload = _unwrapMap(payload);
    return Item.fromJson(itemPayload);
  }

  static dynamic _unwrapData(dynamic payload) {
    if (payload is Map && payload.containsKey('data')) {
      return payload['data'];
    }
    return payload;
  }

  static List<dynamic> _unwrapList(dynamic payload) {
    if (payload is List) {
      return payload;
    }
    if (payload is Map) {
      final possibleLists = [
        payload['items'],
        payload['results'],
        payload['list'],
        payload['data'],
      ];
      for (final candidate in possibleLists) {
        if (candidate is List) {
          return candidate;
        }
      }
    }
    return const [];
  }

  static Map<String, dynamic> _unwrapMap(dynamic payload) {
    if (payload is Map) {
      if (payload['item'] is Map) {
        return Map<String, dynamic>.from(payload['item'] as Map);
      }
      if (payload['data'] is Map) {
        return Map<String, dynamic>.from(payload['data'] as Map);
      }
      return Map<String, dynamic>.from(payload);
    }
    return <String, dynamic>{};
  }
}
