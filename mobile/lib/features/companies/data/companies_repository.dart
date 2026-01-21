import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/company.dart';

final companiesRepositoryProvider = Provider<CompaniesRepository>((ref) {
  return CompaniesRepository(apiClient: ref.read(apiClientProvider));
});

final companiesSearchProvider = StateProvider<String>((ref) => '');

final companiesProvider = FutureProvider.autoDispose<List<CompanySummary>>((ref) async {
  final repo = ref.read(companiesRepositoryProvider);
  final search = ref.watch(companiesSearchProvider);
  return repo.fetchCompanies(search: search);
});

final companyDetailProvider = FutureProvider.autoDispose.family<CompanyDetail, String>((ref, id) async {
  final repo = ref.read(companiesRepositoryProvider);
  return repo.fetchCompanyDetail(id);
});

class CompaniesRepository {
  final ApiClient apiClient;

  CompaniesRepository({required this.apiClient});

  Future<List<CompanySummary>> fetchCompanies({String? search}) async {
    final response = await apiClient.getCompanies(search: search);
    final raw = response.data;

    // متوقع شكل: { data: [ ... ], meta: ... }
    final data = (raw is Map<String, dynamic>) ? raw['data'] : null;
    final list = (data is List) ? data : <dynamic>[];

    return list
        .whereType<Map>()
        .map((e) => CompanySummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<CompanyDetail> fetchCompanyDetail(String id) async {
    final response = await apiClient.getCompanyById(id);
    final raw = response.data;

    // متوقع شكل: { data: { company: {...}, products: [...] } }
    final data = (raw is Map<String, dynamic>) ? raw['data'] : null;
    if (data is! Map) {
      throw Exception('Invalid response from /companies/$id');
    }

    return CompanyDetail.fromJson(Map<String, dynamic>.from(data));
  }
}
