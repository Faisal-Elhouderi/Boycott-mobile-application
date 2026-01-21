import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(apiClient: ref.read(apiClientProvider));
});

final profileProvider = FutureProvider.autoDispose<ProfileSummary>((ref) async {
  final repository = ref.read(profileRepositoryProvider);
  return repository.fetchProfile();
});

class ProfileRepository {
  final ApiClient apiClient;

  ProfileRepository({required this.apiClient});

  Future<ProfileSummary> fetchProfile() async {
    final response = await apiClient.getProfile();
    final mapPayload = unwrapSuccessMap(response.data);
    return ProfileSummary.fromJson(mapPayload);
  }
}
