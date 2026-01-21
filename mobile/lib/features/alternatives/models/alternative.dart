import '../../products/models/product.dart';

class AlternativeSummary {
  final String id;
  final String name;
  final String brand;
  final String company;
  final String category;
  final String description;
  final String reason;
  final String iconKey;
  final String verdict;
  final String verdictLabel;

  const AlternativeSummary({
    required this.id,
    required this.name,
    required this.brand,
    required this.company,
    required this.category,
    required this.description,
    required this.reason,
    required this.iconKey,
    required this.verdict,
    required this.verdictLabel,
  });

  factory AlternativeSummary.fromJson(Map<String, dynamic> json) {
    return AlternativeSummary(
      id: _readString(json, 'id'),
      name: _readString(json, 'name'),
      brand: _readString(json, 'brand'),
      company: _readString(json, 'company'),
      category: _readString(json, 'category'),
      description: _readString(json, 'description'),
      reason: _readString(json, 'reason'),
      iconKey: _readString(json, 'iconKey'),
      verdict: _readString(json, 'verdict'),
      verdictLabel: _readString(json, 'verdictLabel'),
    );
  }

  String get displayName => name.isNotEmpty ? name : 'بديل بدون اسم';

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }
}

class AlternativeDetail {
  final AlternativeSummary alternative;
  final List<ProductSummary> linkedProducts;

  const AlternativeDetail({
    required this.alternative,
    required this.linkedProducts,
  });

  factory AlternativeDetail.fromJson(Map<String, dynamic> json) {
    final alternativeJson = json['alternative'] is Map
        ? Map<String, dynamic>.from(json['alternative'] as Map)
        : <String, dynamic>{};
    final productsJson = json['linkedProducts'] is List
        ? json['linkedProducts'] as List
        : const [];

    return AlternativeDetail(
      alternative: AlternativeSummary.fromJson(alternativeJson),
      linkedProducts: productsJson
          .whereType<Map>()
          .map((entry) =>
              ProductSummary.fromJson(Map<String, dynamic>.from(entry)))
          .toList(),
    );
  }
}
