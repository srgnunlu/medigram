import 'package:dio/dio.dart';
import 'package:medigram/data/models/user.dart';
import 'package:medigram/data/services/api_client.dart';
import 'package:medigram/data/services/storage_service.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();

  // Login
  Future<AuthResponse> login({
    required String identifier, // email or username
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/local',
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Save token and user data
      await _storage.saveToken(authResponse.jwt);
      await _storage.saveUser(authResponse.user.toJson());

      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Register
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/local/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Save token and user data
      await _storage.saveToken(authResponse.jwt);
      await _storage.saveUser(authResponse.user.toJson());

      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearAll();
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final userData = await _storage.getUser();
      if (userData != null) {
        return User.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Reset password
  Future<void> resetPassword({
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _apiClient.post(
        '/auth/reset-password',
        data: {
          'code': code,
          'password': password,
          'passwordConfirmation': passwordConfirmation,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          final errorData = data['error'];
          if (errorData is Map && errorData.containsKey('message')) {
            return errorData['message'].toString();
          }
          return errorData.toString();
        }
        if (data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      return 'An error occurred: ${error.response!.statusCode}';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to connect to the server. Please check your internet connection.';
    }

    return 'An unexpected error occurred. Please try again.';
  }
}
