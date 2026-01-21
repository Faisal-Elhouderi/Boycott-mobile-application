import '../../products/models/product.dart';

class CompanySummary {
  final String id;
  final String name;
  final String description;
  final String country;
  final String verdict;
  final String verdictLabel;
  final String iconKey;

  const CompanySummary({
    required this.id,
    required this.name,
    required this.description,
    required this.country,
    required this.verdict,
    required this.verdictLabel,
    required this.iconKey,
  });

  factory CompanySummary.fromJson(Map<String, dynamic> json) {
    return CompanySummary(
      id: _readString(json, 'id'),
      name: _readString(json, 'name'),
      description: _readString(json, 'description'),
      country: _readString(json, 'country'),
      verdict: _readString(json, 'verdict'),
      verdictLabel: _readString(json, 'verdictLabel'),
      iconKey: _readString(json, 'iconKey'),
    );
  }

  String get displayName => name.isNotEmpty ? name : 'شركة بدون اسم';

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }
}

class CompanyDetail {
  final CompanySummary company;
  final List<ProductSummary> products;

  const CompanyDetail({
    required this.company,
    required this.products,
  });

  factory CompanyDetail.fromJson(Map<String, dynamic> json) {
    final companyJson = json['company'] is Map
        ? Map<String, dynamic>.from(json['company'] as Map)
        : <String, dynamic>{};
    final productsJson = json['products'] is List ? json['products'] as List : const [];

    return CompanyDetail(
      company: CompanySummary.fromJson(companyJson),
      products: productsJson
          .whereType<Map>()
          .map((entry) =>
              ProductSummary.fromJson(Map<String, dynamic>.from(entry)))
          .toList(),
    );
  }
}
