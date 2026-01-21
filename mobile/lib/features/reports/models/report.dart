class Report {
  final String? id;
  final String title;
  final String description;
  final String? status;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.raw,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: _firstString(json, ['id', '_id', 'reportId']),
      title: _firstString(json, ['name', 'company', 'title', 'subject']) ??
          'بلاغ بدون عنوان',
      description:
          _firstString(json, ['reason', 'description', 'message', 'details']) ??
              '',
      status: _firstString(json, ['status', 'state']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      raw: json,
    );
  }

  String get displayTitle => title.isNotEmpty ? title : 'بلاغ بدون عنوان';

  static DateTime? _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  static String? _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
      if (value != null && value is! Map && value is! List) {
        final asString = value.toString();
        if (asString.trim().isNotEmpty) {
          return asString;
        }
      }
    }
    return null;
  }
}
