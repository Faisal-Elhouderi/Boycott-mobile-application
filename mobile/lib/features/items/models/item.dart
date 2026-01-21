class Item {
  final String? id;
  final String name;
  final String? category;
  final String? description;
  final String? status;
  final String? imageUrl;
  final Map<String, dynamic> raw;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.status,
    required this.imageUrl,
    required this.raw,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    final name = _firstString(json, ['name', 'title', 'label']) ?? 'عنصر بدون عنوان';
    return Item(
      id: _firstString(json, ['id', '_id', 'itemId']),
      name: name,
      category: _firstString(json, ['category', 'type', 'group']),
      description: _firstString(json, ['description', 'details', 'summary']),
      status: _firstString(json, ['status', 'verdict', 'state']),
      imageUrl: _firstString(json, ['imageUrl', 'image', 'thumbnail', 'logo']),
      raw: json,
    );
  }

  String get displayName => name.isNotEmpty ? name : 'عنصر بدون عنوان';

  Map<String, dynamic> get extraFields {
    const knownKeys = {
      'id',
      '_id',
      'itemId',
      'name',
      'title',
      'label',
      'category',
      'type',
      'group',
      'description',
      'details',
      'summary',
      'status',
      'verdict',
      'state',
      'imageUrl',
      'image',
      'thumbnail',
      'logo',
    };
    return raw.entries
        .where((entry) => !knownKeys.contains(entry.key))
        .fold<Map<String, dynamic>>({}, (map, entry) {
      map[entry.key] = entry.value;
      return map;
    });
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
