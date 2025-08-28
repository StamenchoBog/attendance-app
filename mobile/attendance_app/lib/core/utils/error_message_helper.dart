class ErrorMessageHelper {
  static String getDeviceRegistrationErrorMessage(String errorCode, String? fallbackMessage) {
    switch (errorCode) {
      case 'DEVICE_ALREADY_REGISTERED':
        return 'You already have a registered device. To change devices, please use the device change request feature in your profile settings.';
      case 'DEVICE_NOT_REGISTERED':
        return 'This device is not registered for attendance. Please register your device first or use your registered device.';
      case 'INVALID_INPUT':
        return 'Invalid device information. Please try again.';
      case 'REGISTRATION_FAILED':
        return 'Failed to register your device. Please check your internet connection and try again.';
      case 'NETWORK_ERROR':
        return 'Unable to connect to the server. Please check your internet connection and try again.';
      case 'SERVER_ERROR':
        return 'Server is temporarily unavailable. Please try again in a few moments.';
      case 'DEVICE_ID_ERROR':
        return 'Unable to identify your device. Please restart the app and try again.';
      case 'STUDENT_NOT_FOUND':
        return 'Student information not found. Please contact support.';
      case 'TOKEN_EXPIRED':
        return 'Your session has expired. Please log in again.';
      case 'INVALID_TOKEN':
        return 'Invalid attendance code. Please scan a valid QR code from your professor.';
      case 'ATTENDANCE_ALREADY_REGISTERED':
        return 'You have already marked attendance for this session.';
      case 'SESSION_EXPIRED':
        return 'The attendance session has expired. Please ask your professor to generate a new QR code.';
      default:
        return fallbackMessage ?? 'An unexpected error occurred. Please try again.';
    }
  }

  static String getAttendanceErrorMessage(String errorCode, String? fallbackMessage) {
    switch (errorCode) {
      case 'DEVICE_NOT_REGISTERED':
        return 'Cannot mark attendance: Your device is not registered. Please register your device in settings.';
      case 'INVALID_TOKEN':
        return 'Invalid QR code. Please scan the QR code displayed by your professor.';
      case 'TOKEN_EXPIRED':
        return 'This attendance session has expired. Please ask your professor for a new QR code.';
      case 'ATTENDANCE_ALREADY_REGISTERED':
        return 'You have already marked attendance for this class session.';
      case 'STUDENT_NOT_VALID':
        return 'Student verification failed. Please contact support.';
      case 'PROXIMITY_CHECK_FAILED':
        return 'Unable to verify your location. Please ensure Bluetooth is enabled and you are in the classroom.';
      default:
        return fallbackMessage ?? 'Failed to mark attendance. Please try again.';
    }
  }

  static bool isRetryableError(String errorCode) {
    const retryableErrors = ['NETWORK_ERROR', 'SERVER_ERROR', 'REGISTRATION_FAILED', 'DEVICE_ID_ERROR'];
    return retryableErrors.contains(errorCode);
  }

  static bool requiresDeviceRegistration(String errorCode) {
    const deviceErrors = ['DEVICE_NOT_REGISTERED', 'DEVICE_ALREADY_REGISTERED'];
    return deviceErrors.contains(errorCode);
  }
}
