import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../auth_service.dart';

class ApiClient {
  final AuthService _authService = AuthService();
  final String _baseUrl = dotenv.env['API_URL'] ?? '';
  
  // GET request with authentication
  Future<dynamic> get(String endpoint) async {
    final client = await _authService.getAuthClient();
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return _handleResponse(response);
    } finally {
      client.close();
    }
  }
  
  // POST request with authentication
  Future<dynamic> post(String endpoint, dynamic data) async {
    final client = await _authService.getAuthClient();
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } finally {
      client.close();
    }
  }
  
  // PUT request with authentication
  Future<dynamic> put(String endpoint, dynamic data) async {
    final client = await _authService.getAuthClient();
    try {
      final response = await client.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } finally {
      client.close();
    }
  }
  
  // DELETE request with authentication
  Future<dynamic> delete(String endpoint) async {
    final client = await _authService.getAuthClient();
    try {
      final response = await client.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return _handleResponse(response);
    } finally {
      client.close();
    }
  }

  // POST request that returns raw bytes
  Future<Uint8List> postAndGetBytes(String endpoint, dynamic data) async {
    final client = await _authService.getAuthClient();
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: response.body,
        );
      }
    } finally {
      client.close();
    }
  }
  
  // Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired or invalid
      throw UnauthorizedException('Unauthorized: ${response.body}');
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: response.body,
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  
  ApiException({required this.statusCode, required this.message});
  
  @override
  String toString() => 'ApiException: $statusCode - $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) 
      : super(statusCode: 401, message: message);
}