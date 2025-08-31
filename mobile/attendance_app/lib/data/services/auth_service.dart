import 'dart:convert';
import 'package:attendance_app/core/utils/storage_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:attendance_app/core/utils/error_handler.dart';
import '../models/user.dart';

// Custom exception for authentication errors that works with ErrorHandler
class AuthenticationException implements Exception {
  final String message;
  final int? statusCode;

  AuthenticationException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthService {
  final _secureStorage = const FlutterSecureStorage();
  final String _baseUrl = dotenv.env['API_URL'] ?? '';
  late final Dio _dio;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  // Get stored JWT token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageKeys.jwtToken);
  }

  // Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: StorageKeys.refreshToken);
  }

  // Store JWT token
  Future<void> storeToken(String token) async {
    await _secureStorage.write(key: StorageKeys.jwtToken, value: token);
  }

  // Store refresh token
  Future<void> storeRefreshToken(String token) async {
    await _secureStorage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<void> storeUser(User user) async {
    // Store minimal identifying info
    final userJson = jsonEncode({'id': user.id, 'name': user.name, 'email': user.email, 'role': user.role});

    await _secureStorage.write(key: StorageKeys.currentUser, value: userJson);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<User?> getCurrentUser() async {
    final userJson = await _secureStorage.read(key: StorageKeys.currentUser);
    if (userJson == null) return null;

    final Map<String, dynamic> userData = jsonDecode(userJson);
    // Use your User factory to create the appropriate type
    return User.fromJson(userData);
  }

  // Validates CAS service ticket with your API
  Future<User> validateTicket(String ticket) async {
    return await ErrorHandler.handleAsyncError<User>(
          () async {
            final response = await _dio.post('/auth/validate-ticket', data: {'ticket': ticket});

            final data = response.data;

            // Store tokens
            await storeToken(data['token']);
            if (data['refreshToken'] != null) {
              await storeRefreshToken(data['refreshToken']);
            }

            // Return student information
            return User.fromJson(data['student']);
          },
          'validateTicket',
          showDialog: false,
          showToast: false,
        ) ??
        (throw AuthenticationException('Authentication failed'));
  }

  // Create an HTTP client with auth headers
  Future<Dio> getAuthClient() async {
    final token = await getToken();

    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    return dio;
  }

  // Logout
  Future<void> logout() async {
    await _secureStorage.delete(key: StorageKeys.jwtToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
  }

  // Refresh token
  Future<bool> refreshToken() async {
    final refreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post('/auth/refresh', data: jsonEncode({'refreshToken': refreshToken}));

      if (response.statusCode == 200) {
        final data = response.data;
        await storeToken(data['token']);

        // Store new refresh token if provided
        if (data['refreshToken'] != null) {
          await storeRefreshToken(data['refreshToken']);
        }

        return true;
      } else {
        // Refresh token is invalid
        await logout();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Refresh JWT token using refresh token
  Future<String?> refreshTokenWithRefreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        if (newAccessToken != null) {
          await storeToken(newAccessToken);
          if (newRefreshToken != null) {
            await storeRefreshToken(newRefreshToken);
          }
          return newAccessToken;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Clear all stored tokens (logout)
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: StorageKeys.jwtToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _secureStorage.delete(key: StorageKeys.currentUser);
  }
}
