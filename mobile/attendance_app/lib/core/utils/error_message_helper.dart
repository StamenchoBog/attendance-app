import 'package:attendance_app/core/utils/error_handler.dart';

/// Helper class for centralized error message management
class ErrorMessageHelper {
  // Repository-specific error messages
  static const String attendanceRegistrationFailed = 'Failed to register attendance. Please try again.';
  static const String attendanceConfirmationFailed = 'Failed to confirm attendance. Please try again.';
  static const String studentDataLoadFailed = 'Failed to load student data. Please try again.';
  static const String professorDataLoadFailed = 'Failed to load professor data. Please try again.';
  static const String classSessionLoadFailed = 'Failed to load class session data. Please try again.';
  static const String proximityVerificationFailed = 'Failed to verify proximity. Please try again.';
  static const String reportSubmissionFailed = 'Failed to submit report. Please try again.';
  static const String roomDataLoadFailed = 'Failed to load room data. Please try again.';
  static const String subjectDataLoadFailed = 'Failed to load subject data. Please try again.';

  /// Gets a user-friendly error message for the given error
  static String getErrorMessage(dynamic error) {
    return ErrorHandler.getErrorMessage(error);
  }

  /// Gets a specific error message for repository operations
  static String getRepositoryErrorMessage(String repositoryName, String operation, [dynamic error]) {
    if (error != null) {
      final specificMessage = ErrorHandler.getErrorMessage(error);
      if (specificMessage != ErrorHandler.unknownError) {
        return specificMessage;
      }
    }

    // Fallback to operation-specific messages
    final key = '${repositoryName.toLowerCase()}_${operation.toLowerCase()}';
    switch (key) {
      case 'attendance_register':
        return attendanceRegistrationFailed;
      case 'attendance_confirm':
        return attendanceConfirmationFailed;
      case 'student_load':
      case 'student_get':
        return studentDataLoadFailed;
      case 'professor_load':
      case 'professor_get':
        return professorDataLoadFailed;
      case 'classsession_load':
      case 'classsession_get':
        return classSessionLoadFailed;
      case 'proximityverification_verify':
        return proximityVerificationFailed;
      case 'report_submit':
        return reportSubmissionFailed;
      case 'room_load':
      case 'room_get':
        return roomDataLoadFailed;
      case 'subject_load':
      case 'subject_get':
        return subjectDataLoadFailed;
      default:
        return ErrorHandler.unknownError;
    }
  }

  /// Formats error message with additional context
  static String formatErrorWithContext(String operation, dynamic error) {
    final baseMessage = ErrorHandler.getErrorMessage(error);
    return 'Error during $operation: $baseMessage';
  }

  /// Gets attendance error message with specific context
  static String getAttendanceErrorMessage(dynamic error, [String? context]) {
    final baseMessage = ErrorHandler.getErrorMessage(error);
    if (context != null) {
      return '$context: $baseMessage';
    }
    return baseMessage.contains('attendance') ? baseMessage : 'Attendance operation failed. Please try again.';
  }

  /// Gets device registration error message with specific context
  static String getDeviceRegistrationErrorMessage(dynamic error, [String? context]) {
    final baseMessage = ErrorHandler.getErrorMessage(error);
    if (context != null) {
      return '$context: $baseMessage';
    }
    return baseMessage.contains('device') ? baseMessage : 'Device registration failed. Please try again.';
  }

  /// Checks if an error is retryable
  static bool isRetryableError(dynamic error) {
    if (error == null) return false;

    final message = ErrorHandler.getErrorMessage(error).toLowerCase();

    // Network-related errors are typically retryable
    if (message.contains('network') ||
        message.contains('timeout') ||
        message.contains('connection') ||
        message.contains('server error')) {
      return true;
    }

    // Authentication and validation errors are typically not retryable
    if (message.contains('authentication') || message.contains('invalid data') || message.contains('access denied')) {
      return false;
    }

    return true; // Default to retryable for unknown errors
  }
}
