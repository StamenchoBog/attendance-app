import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../auth_service.dart';

class ApiClient {
  late final Dio _dio;
  final AuthService _authService = AuthService();
  final Logger _logger = Logger();
  final String _baseUrl = dotenv.env['API_URL'] ?? '';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Auth interceptor - automatically adds JWT token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _logger.d('${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) async {
          _logger.e('${error.response?.statusCode} ${error.requestOptions.path}: ${error.message}');

          // Auto-retry on token expiration
          if (error.response?.statusCode == 401) {
            // Try to get a fresh token (assuming refresh token exists)
            final refreshToken = await _authService.getRefreshToken();
            if (refreshToken != null) {
              try {
                final newToken = await _authService.refreshTokenWithRefreshToken(refreshToken);
                if (newToken != null) {
                  // Retry the original request with new token
                  final options = error.requestOptions;
                  options.headers['Authorization'] = 'Bearer $newToken';

                  final response = await _dio.fetch(options);
                  handler.resolve(response);
                  return;
                }
              } catch (e) {
                _logger.e('Failed to refresh token: $e');
                // Could redirect to login here
              }
            }
          }

          handler.next(error);
        },
      ),
    );

    // Logging interceptor for development
    if (dotenv.env['ENVIRONMENT'] == 'dev') {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, logPrint: (obj) => _logger.d(obj.toString())),
      );
    }
  }

  // GET request
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.delete<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Download file
  Future<Response> download(String urlPath, String savePath, {ProgressCallback? onReceiveProgress}) async {
    try {
      return await _dio.download(urlPath, savePath, onReceiveProgress: onReceiveProgress);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Upload file
  Future<Response<T>> upload<T>(String path, FormData formData, {ProgressCallback? onSendProgress}) async {
    try {
      return await _dio.post<T>(
        path,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          statusCode: 408,
          message: 'Connection timeout. Please check your internet connection.',
          type: ApiExceptionType.timeout,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          statusCode: error.response?.statusCode ?? 0,
          message: error.response?.data?['message'] ?? 'Server error occurred',
          type: ApiExceptionType.server,
        );
      case DioExceptionType.cancel:
        return const ApiException(statusCode: 0, message: 'Request was cancelled', type: ApiExceptionType.cancel);
      case DioExceptionType.connectionError:
        return const ApiException(statusCode: 0, message: 'No internet connection', type: ApiExceptionType.network);
      default:
        return ApiException(
          statusCode: 0,
          message: error.message ?? 'Unknown error occurred',
          type: ApiExceptionType.unknown,
        );
    }
  }
}

// Enhanced error handling
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final ApiExceptionType type;

  const ApiException({required this.statusCode, required this.message, required this.type});

  @override
  String toString() => 'ApiException: $message (Code: $statusCode)';
}

enum ApiExceptionType { network, timeout, server, cancel, unknown }
