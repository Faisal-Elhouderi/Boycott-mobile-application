class ProductSummary {
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

  const ProductSummary({
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

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
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

  String get displayName => name.isNotEmpty ? name : 'منتج بدون اسم';

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }
}

class ProductDetail {
  final ProductSummary product;
  final List<ProductSummary> alternatives;

  const ProductDetail({
    required this.product,
    required this.alternatives,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'] is Map
        ? Map<String, dynamic>.from(json['product'] as Map)
        : <String, dynamic>{};
    final alternativesJson = json['alternatives'] is List
        ? json['alternatives'] as List
        : const [];

    return ProductDetail(
      product: ProductSummary.fromJson(productJson),
      alternatives: alternativesJson
          .whereType<Map>()
          .map((entry) =>
              ProductSummary.fromJson(Map<String, dynamic>.from(entry)))
          .toList(),
    );
  }
}
