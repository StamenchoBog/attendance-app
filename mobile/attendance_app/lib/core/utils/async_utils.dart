import 'dart:async';
import 'dart:ui';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

/// Utility class for common async operations to reduce code duplication
class AsyncUtils {
  static final Logger _logger = Logger();

  /// Execute operation with timeout and retry logic
  static Future<T> withTimeout<T>(
    Future<T> Function() operation, {
    Duration? timeout,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    timeout ??= AppConstants.networkTimeout;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await operation().timeout(timeout);
      } catch (e) {
        if (attempt == maxRetries - 1) rethrow;
        await Future.delayed(retryDelay);
      }
    }
    throw TimeoutException('Operation failed after $maxRetries attempts', timeout);
  }

  /// Debounce function calls
  static Timer? _debounceTimer;

  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function calls
  static DateTime? _lastThrottleTime;

  static void throttle(VoidCallback callback, {Duration duration = const Duration(milliseconds: 500)}) {
    final now = DateTime.now();
    if (_lastThrottleTime == null || now.difference(_lastThrottleTime!) > duration) {
      _lastThrottleTime = now;
      callback();
    }
  }

  /// Safe async operation that won't throw
  static Future<T?> safeAsync<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      _logger.e('Safe async operation failed: $e');
      return null;
    }
  }

  /// Execute multiple operations concurrently
  static Future<List<T?>> concurrent<T>(List<Future<T> Function()> operations) async {
    final futures = operations.map((op) => safeAsync(op)).toList();
    return await Future.wait(futures);
  }

  /// Dispose timer resources
  static void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _lastThrottleTime = null;
  }
}
