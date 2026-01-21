import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String rootUrl = 'http://10.0.2.2:3000';
  static const String baseUrl = '$rootUrl/api'; // Change for production

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized - clear token
          _storage.delete(key: _tokenKey);
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> pingHealth() async {
    try {
      final response = await _dio.getUri(Uri.parse('$rootUrl/health'));
      print('API health: ${response.data}');
    } catch (error) {
      print('API health check failed: $error');
    }
  }

  // Auth
  Future<Response> register(Map<String, dynamic> data) {
    return _dio.post('/auth/register', data: data);
  }

  Future<Response> login(Map<String, dynamic> data) {
    return _dio.post('/auth/login', data: data);
  }

  Future<Response> getMe() {
    return _dio.get('/auth/me');
  }

  // Products
  Future<Response> getProducts({String? search, String? category}) {
    return _dio.get('/products', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null) 'category': category,
    });
  }

  Future<Response> getProductById(String id) {
    return _dio.get('/products/$id');
  }

  // Companies
  Future<Response> getCompanies({String? search}) {
    return _dio.get('/companies', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
    });
  }

  Future<Response> getCompanyById(String id) {
    return _dio.get('/companies/$id');
  }

  // Alternatives
  Future<Response> getAlternatives({String? search}) {
    return _dio.get('/alternatives', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
    });
  }

  Future<Response> getAlternativeById(String id) {
    return _dio.get('/alternatives/$id');
  }

  // Community
  Future<Response> getCommunitySuggestions({String sort = 'top'}) {
    return _dio.get('/community/suggestions', queryParameters: {
      'sort': sort,
    });
  }

  Future<Response> createCommunitySuggestion(Map<String, dynamic> data) {
    return _dio.post('/community/suggestions', data: data);
  }

  Future<Response> toggleCommunityLike(String id) {
    return _dio.post('/community/suggestions/$id/like');
  }

  // Profile
  Future<Response> getProfile() {
    return _dio.get('/profile/me');
  }

  // Markets
  Future<Response> getMarkets({String? search, String? city}) {
    return _dio.get('/markets', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (city != null && city.isNotEmpty) 'city': city,
    });
  }

  // Items (legacy)
  Future<Response> getItems() {
    return _dio.get('/items');
  }

  Future<Response> getItemById(String id) {
    return _dio.get('/items/$id');
  }

  // Reports
  Future<Response> createReport(Map<String, dynamic> data) {
    return _dio.post('/reports', data: data);
  }

  // Debug
  Future<Response> getHealth() {
    return _dio.getUri(Uri.parse('$rootUrl/health'));
  }
}
