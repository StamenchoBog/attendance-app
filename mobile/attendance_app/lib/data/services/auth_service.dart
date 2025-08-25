import 'dart:convert';
import 'package:attendance_app/core/utils/storage_keys.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';

class AuthService {
  final _secureStorage = const FlutterSecureStorage();
  final String _baseUrl = dotenv.env['API_URL'] ?? '';
  
  // Get stored JWT token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageKeys.jwtToken);
  }
  
  // Store JWT token
  Future<void> storeToken(String token) async {
    await _secureStorage.write(key: StorageKeys.jwtToken, value: token);
  }
  
  // Store refresh token (optional)
  Future<void> storeRefreshToken(String token) async {
    await _secureStorage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<void> storeUser(User user) async {
    // Store minimal identifying info
    final userJson = jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': user.role,
    });
    
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
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/validate-ticket'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ticket': ticket}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Store tokens
      await storeToken(data['token']);
      if (data['refreshToken'] != null) {
        await storeRefreshToken(data['refreshToken']);
      }
      
      // Return student information
      return User.fromJson(data['student']);
    } else {
      throw Exception('Failed to validate ticket: ${response.statusCode}');
    }
  }
  
  // Create an HTTP client with auth headers
  Future<http.Client> getAuthClient() async {
    final token = await getToken();
    final client = http.Client();
    
    if (token != null) {
      return _AuthorizedClient(client, token);
    }
    
    return client;
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
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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

}

// Custom HTTP client that adds authorization header
class _AuthorizedClient extends http.BaseClient {
  final http.Client _inner;
  final String _token;
  
  _AuthorizedClient(this._inner, this._token);
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _inner.send(request);
  }
}