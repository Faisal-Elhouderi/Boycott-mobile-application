import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/community_suggestion.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(apiClient: ref.read(apiClientProvider));
});

final communitySortProvider = StateProvider<String>((ref) => 'top');
final communitySearchProvider = StateProvider<String>((ref) => '');

final communitySuggestionsProvider = FutureProvider.autoDispose<List<CommunitySuggestion>>((ref) async {
  final repository = ref.read(communityRepositoryProvider);
  final sort = ref.watch(communitySortProvider);
  final search = ref.watch(communitySearchProvider);
  final suggestions = await repository.fetchSuggestions(sort: sort);
  if (search.trim().isEmpty) return suggestions;
  final query = search.trim();
  return suggestions
      .where((item) =>
          item.text.contains(query) || item.companyName.contains(query))
      .toList();
});

class CommunityRepository {
  final ApiClient apiClient;

  CommunityRepository({required this.apiClient});

  Future<List<CommunitySuggestion>> fetchSuggestions({String sort = 'top'}) async {
    final response = await apiClient.getCommunitySuggestions(sort: sort);
    final listPayload = unwrapSuccessList(response.data);
    return listPayload
        .whereType<Map>()
        .map((entry) =>
            CommunitySuggestion.fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }

  Future<CommunitySuggestion?> createSuggestion({
    required String text,
    String? companyName,
  }) async {
    final response = await apiClient.createCommunitySuggestion({
      'text': text,
      if (companyName != null && companyName.trim().isNotEmpty)
        'companyName': companyName.trim(),
    });
    final mapPayload = unwrapSuccessMap(response.data);
    if (mapPayload.isEmpty) return null;
    return CommunitySuggestion.fromJson(mapPayload);
  }

  Future<CommunityLikeResult> toggleLike(String suggestionId) async {
    final response = await apiClient.toggleCommunityLike(suggestionId);
    final mapPayload = unwrapSuccessMap(response.data);
    return CommunityLikeResult.fromJson(mapPayload);
  }
}
