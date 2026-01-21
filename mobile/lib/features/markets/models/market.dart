class Market {
  final String id;
  final String name;
  final String city;
  final String area;
  final String address;
  final bool isVerified;

  const Market({
    required this.id,
    required this.name,
    required this.city,
    required this.area,
    required this.address,
    required this.isVerified,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: _readString(json, 'id'),
      name: _readString(json, 'name'),
      city: _readString(json, 'city'),
      area: _readString(json, 'area'),
      address: _readString(json, 'address'),
      isVerified: json['isVerified'] == true,
    );
  }

  String get displayName => name.isNotEmpty ? name : 'سوق بدون اسم';

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return '';
    return value.toString();
  }
}
