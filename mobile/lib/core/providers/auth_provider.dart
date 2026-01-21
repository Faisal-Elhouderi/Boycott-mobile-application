import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../features/auth/models/user.dart';
import 'package:dio/dio.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthNotifier(apiClient);
});

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    required this.user,
    required this.isLoading,
    required this.errorMessage,
  });

  bool get isLoggedIn => user != null && user!.id.isNotEmpty;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;

  AuthNotifier(this._apiClient)
      : super(const AuthState(user: null, isLoading: true, errorMessage: null)) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final token = await _apiClient.getToken();
      if (token == null) {
        state = state.copyWith(isLoading: false, user: null);
        return;
      }
      final response = await _apiClient.getMe();
      final data = unwrapSuccessMap(response.data);
      final userData = data['user'] is Map ? Map<String, dynamic>.from(data['user']) : data;
      state = state.copyWith(
        user: AppUser.fromJson(userData),
        isLoading: false,
        errorMessage: null,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false, user: null);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _apiClient.login({
        'email': email,
        'password': password,
      });
      final data = unwrapSuccessMap(response.data);
      final token = data['token']?.toString();
      final userData = data['user'] is Map ? Map<String, dynamic>.from(data['user']) : <String, dynamic>{};
      if (token != null && token.isNotEmpty) {
        await _apiClient.setToken(token);
      }
      state = state.copyWith(
        user: AppUser.fromJson(userData),
        isLoading: false,
      );
    } on DioException catch (error) {
      final message = _errorMessage(error);
      state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _apiClient.register({
        'name': name,
        'email': email,
        'password': password,
      });
      final data = unwrapSuccessMap(response.data);
      final token = data['token']?.toString();
      final userData = data['user'] is Map ? Map<String, dynamic>.from(data['user']) : <String, dynamic>{};
      if (token != null && token.isNotEmpty) {
        await _apiClient.setToken(token);
      }
      state = state.copyWith(
        user: AppUser.fromJson(userData),
        isLoading: false,
      );
    } on DioException catch (error) {
      final message = _errorMessage(error);
      state = state.copyWith(isLoading: false, errorMessage: message);
    }
  }

  Future<void> logout() async {
    await _apiClient.clearToken();
    state = state.copyWith(user: null, errorMessage: null, isLoading: false);
  }

  static String _errorMessage(DioException error) {
    final response = error.response?.data;
    if (response is Map) {
      final errorMap = response['error'];
      if (errorMap is Map && errorMap['message'] != null) {
        return errorMap['message'].toString();
      }
    }
    return error.message ?? 'حدث خطأ';
  }
}

