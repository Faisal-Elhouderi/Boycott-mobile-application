import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/report.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(apiClient: ref.read(apiClientProvider));
});

class ReportsRepository {
  final ApiClient apiClient;

  ReportsRepository({required this.apiClient});

  Future<Report?> submitReport(Map<String, dynamic> data) async {
    final response = await apiClient.createReport(data);
    final mapPayload = unwrapSuccessMap(response.data);
    if (mapPayload.isEmpty) {
      return null;
    }
    return Report.fromJson(mapPayload);
  }
}
