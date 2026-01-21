import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/product.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(apiClient: ref.read(apiClientProvider));
});

final productsSearchProvider = StateProvider<String>((ref) => '');

final productsProvider = FutureProvider.autoDispose<List<ProductSummary>>((ref) async {
  final repository = ref.read(productsRepositoryProvider);
  final search = ref.watch(productsSearchProvider);
  return repository.fetchProducts(search: search);
});

final productDetailProvider = FutureProvider.autoDispose.family<ProductDetail, String>((ref, id) async {
  final repository = ref.read(productsRepositoryProvider);
  return repository.fetchProductDetail(id);
});

class ProductsRepository {
  final ApiClient apiClient;

  ProductsRepository({required this.apiClient});

  Future<List<ProductSummary>> fetchProducts({String? search}) async {
    final response = await apiClient.getProducts(search: search);
    final listPayload = unwrapSuccessList(response.data);
    return listPayload
        .whereType<Map>()
        .map((entry) =>
            ProductSummary.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  Future<ProductDetail> fetchProductDetail(String id) async {
    final response = await apiClient.getProductById(id);
    final mapPayload = unwrapSuccessMap(response.data);
    return ProductDetail.fromJson(mapPayload);
  }
}
