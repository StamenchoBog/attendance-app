import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Standardized error handler for repositories
class ErrorHandler {
  static final Logger _logger = Logger();

  // Error message constants
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String timeoutError = 'Request timeout. Please try again.';
  static const String unauthorizedError = 'Authentication failed. Please log in again.';
  static const String forbiddenError = 'Access denied. You don\'t have permission to perform this action.';
  static const String notFoundError = 'Requested resource not found.';
  static const String validationError = 'Invalid data provided. Please check your input.';
  static const String attendanceError = 'Attendance operation failed. Please try again.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';

  /// Handles async operations with standardized error handling
  ///
  /// [operation] - The async operation to execute
  /// [operationName] - Name of the operation for logging purposes
  /// [showDialog] - Whether to show error dialog to user (default: true)
  /// [showToast] - Whether to show error toast to user (default: false)
  /// [context] - BuildContext for showing dialogs (optional)
  ///
  /// Returns the result of the operation or null if an error occurred
  static Future<T?> handleAsyncError<T>(
    Future<T> Function() operation,
    String operationName, {
    bool showDialog = true,
    bool showToast = false,
    BuildContext? context,
  }) async {
    // Store context locally to avoid async gap issues
    final localContext = context;

    try {
      _logger.d('Starting operation: $operationName');
      final result = await operation();
      _logger.d('Operation completed successfully: $operationName');
      return result;
    } catch (error) {
      _logger.e('Error in $operationName: $error');

      final errorMessage = getErrorMessage(error);

      if (showToast) {
        _showToast(errorMessage);
      }

      if (showDialog && localContext != null && localContext.mounted) {
        _showErrorDialog(localContext, errorMessage, operationName);
      }

      return null;
    }
  }

  /// Handles async operations that don't return a value
  ///
  /// [operation] - The async operation to execute
  /// [operationName] - Name of the operation for logging purposes
  /// [showDialog] - Whether to show error dialog to user (default: true)
  /// [showToast] - Whether to show error toast to user (default: false)
  /// [context] - BuildContext for showing dialogs (optional)
  ///
  /// Returns true if successful, false if an error occurred
  static Future<bool> handleAsyncVoidError(
    Future<void> Function() operation,
    String operationName, {
    bool showDialog = true,
    bool showToast = false,
    BuildContext? context,
  }) async {
    // Store context locally to avoid async gap issues
    final localContext = context;

    try {
      _logger.d('Starting operation: $operationName');
      await operation();
      _logger.d('Operation completed successfully: $operationName');
      return true;
    } catch (error) {
      _logger.e('Error in $operationName: $error');

      final errorMessage = getErrorMessage(error);

      if (showToast) {
        _showToast(errorMessage);
      }

      if (showDialog && localContext != null && localContext.mounted) {
        _showErrorDialog(localContext, errorMessage, operationName);
      }

      return false;
    }
  }

  /// Converts various error types to user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return timeoutError;

        case DioExceptionType.connectionError:
          if (error.error is SocketException) {
            return networkError;
          }
          return serverError;

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          switch (statusCode) {
            case 400:
              return validationError;
            case 401:
              return unauthorizedError;
            case 403:
              return forbiddenError;
            case 404:
              return notFoundError;
            case 500:
            case 502:
            case 503:
            case 504:
              return serverError;
            default:
              return _extractErrorMessageFromResponse(error.response) ?? serverError;
          }

        case DioExceptionType.cancel:
          return 'Request was cancelled.';

        case DioExceptionType.unknown:
        default:
          return unknownError;
      }
    }

    if (error is SocketException) {
      return networkError;
    }

    if (error is FormatException) {
      return 'Invalid data format received from server.';
    }

    // Try to extract message from exception
    if (error is Exception) {
      final message = error.toString();
      if (message.contains('Exception:')) {
        return message.replaceFirst('Exception:', '').trim();
      }
    }

    return unknownError;
  }

  /// Extracts error message from API response
  static String? _extractErrorMessageFromResponse(Response? response) {
    try {
      final data = response?.data;
      if (data is Map<String, dynamic>) {
        // Common API error message fields
        return data['message'] ?? data['error'] ?? data['detail'] ?? data['errorMessage'];
      }
    } catch (e) {
      _logger.w('Failed to extract error message from response: $e');
    }
    return null;
  }

  /// Shows error toast message
  static void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red[600],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Handles repository operations with standardized error handling and specific error message extraction
  ///
  /// [operation] - The async operation to execute
  /// [repositoryName] - Name of the repository for logging purposes
  /// [operationName] - Name of the operation for logging purposes
  /// [showDialog] - Whether to show error dialog to user (default: true)
  /// [showToast] - Whether to show error toast to user (default: false)
  /// [context] - BuildContext for showing dialogs (optional)
  ///
  /// Returns the result of the operation or null if an error occurred
  static Future<T?> handleRepositoryError<T>(
    Future<T> Function() operation,
    String repositoryName,
    String operationName, {
    bool showDialog = true,
    bool showToast = false,
    BuildContext? context,
  }) async {
    // Store context locally to avoid async gap issues
    final localContext = context;

    try {
      _logger.d('Starting $repositoryName.$operationName');
      final result = await operation();
      _logger.d('$repositoryName.$operationName completed successfully');
      return result;
    } catch (error) {
      _logger.e('Error in $repositoryName.$operationName: $error');

      String errorMessage = getErrorMessage(error);

      // Enhanced error handling for specific cases
      if (error is DioException && error.response != null) {
        final responseData = error.response!.data;
        if (responseData is Map<String, dynamic>) {
          final serverMessage = responseData['message'] ?? responseData['error'];

          // Handle specific attendance errors
          if (serverMessage != null) {
            final message = serverMessage.toString().toLowerCase();

            // Remove all checks for already registered attendance since the server now handles this case
            if (message.contains('token expired') ||
                message.contains('expired token') ||
                message.contains('token has expired') ||
                message.contains('token has expired') || // Handle the typo in server message
                message.contains('attendance token has expired') ||
                message.contains('attendance token has expred') ||
                message.contains('session expired')) {
              errorMessage = 'The QR code has expired. Please ask your professor to generate a new QR code.';
            } else if (message.contains('invalid token') ||
                message.contains('token not found') ||
                message.contains('invalid qr')) {
              errorMessage = 'Invalid QR code. Please scan a valid attendance QR code.';
            } else if (message.contains('not enrolled') ||
                message.contains('student not found') ||
                message.contains('not registered for')) {
              errorMessage = 'You are not enrolled in this course or session.';
            } else if (message.contains('device not registered') || message.contains('unregistered device')) {
              errorMessage = 'Your device is not registered. Please register your device first.';
            } else if (message.contains('session not active') || message.contains('attendance window closed')) {
              errorMessage = 'The attendance window for this session has closed.';
            } else {
              if (serverMessage.toString().length < 200 &&
                  !serverMessage.toString().contains('Exception') &&
                  !serverMessage.toString().contains('Error:')) {
                errorMessage = serverMessage.toString();
              }
            }
          }
        }
      }

      // Additional fallback check for error string patterns that might not be in the response data
      final errorString = error.toString().toLowerCase();
      if (errorMessage == getErrorMessage(error)) {
        // Only if we haven't already processed it above
        if (errorString.contains('attendance token has expired') ||
            errorString.contains('attendance token has expred') ||
            errorString.contains('token expired') ||
            errorString.contains('token has expired')) {
          errorMessage = 'The QR code has expired. Please ask your professor to generate a new QR code.';
        }
        // Remove the check for already registered attendance here as well
      }

      if (showToast) {
        _showToast(errorMessage);
      }

      if (showDialog && localContext != null && localContext.mounted) {
        _showErrorDialog(localContext, errorMessage, '$repositoryName.$operationName');
      }

      // Re-throw the exception with the processed message for upstream handling
      throw Exception(errorMessage);
    }
  }

  /// Shows error dialog
  static void _showErrorDialog(BuildContext context, String message, String operationName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
          ),
    );
  }

  /// Logs error for debugging purposes
  static void logError(String operationName, dynamic error, [StackTrace? stackTrace]) {
    _logger.e('Error in $operationName: $error', error: error, stackTrace: stackTrace);
  }
}
