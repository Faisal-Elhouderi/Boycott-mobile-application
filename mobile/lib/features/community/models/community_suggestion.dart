class CommunitySuggestion {
  final String id;
  final String text;
  final String companyName;
  final int likesCount;
  final DateTime? createdAt;
  final String authorName;

  const CommunitySuggestion({
    required this.id,
    required this.text,
    required this.companyName,
    required this.likesCount,
    required this.createdAt,
    required this.authorName,
  });

  factory CommunitySuggestion.fromJson(Map<String, dynamic> json) {
    final author = json['author'] is Map ? json['author'] as Map : const {};
    return CommunitySuggestion(
      id: _readString(json, 'id'),
      text: _readString(json, 'text'),
      companyName: _readString(json, 'companyName'),
      likesCount: _readInt(json, 'likesCount'),
      createdAt: _parseDate(json['createdAt']),
      authorName: _readString(author, 'name'),
    );
  }

  String get displayText => text.isNotEmpty ? text : 'اقتراح بدون نص';

  static String _readString(Map json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }

  static int _readInt(Map json, String key) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

class CommunityLikeResult {
  final String suggestionId;
  final bool liked;
  final int likesCount;

  const CommunityLikeResult({
    required this.suggestionId,
    required this.liked,
    required this.likesCount,
  });

  factory CommunityLikeResult.fromJson(Map<String, dynamic> json) {
    return CommunityLikeResult(
      suggestionId: json['suggestionId']?.toString() ?? '',
      liked: json['liked'] == true,
      likesCount: json['likesCount'] is int
          ? json['likesCount'] as int
          : int.tryParse(json['likesCount']?.toString() ?? '') ?? 0,
    );
  }
}
