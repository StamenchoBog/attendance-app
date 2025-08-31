/// Validation utility functions used across the app
class ValidationUtils {
  // Email validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  // Student index validation (assuming format like 123456)
  static bool isValidStudentIndex(String index) {
    return RegExp(r'^\d{6}$').hasMatch(index);
  }

  // Password validation
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Required field validation
  static bool isRequired(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  // Device ID validation
  static bool isValidDeviceId(String deviceId) {
    return deviceId.isNotEmpty && deviceId.length > 10;
  }

  // QR token validation
  static bool isValidQRToken(String token) {
    return token.isNotEmpty && token.length > 20;
  }

  // Room ID validation
  static bool isValidRoomId(String roomId) {
    return roomId.isNotEmpty && roomId != "UNKNOWN_ROOM";
  }

  // RSSI value validation for Bluetooth
  static bool isValidRSSI(int rssi) {
    return rssi >= -120 && rssi <= 0;
  }

  // Distance validation for proximity
  static bool isValidDistance(double distance) {
    return distance >= 0 && distance <= 100; // Max 100 meters
  }

  // Validation error messages
  static String getEmailError(String email) {
    if (!isRequired(email)) return 'Email is required';
    if (!isValidEmail(email)) return 'Please enter a valid email';
    return '';
  }

  static String getStudentIndexError(String index) {
    if (!isRequired(index)) return 'Student index is required';
    if (!isValidStudentIndex(index)) return 'Student index must be 6 digits';
    return '';
  }

  static String getPasswordError(String password) {
    if (!isRequired(password)) return 'Password is required';
    if (!isValidPassword(password)) return 'Password must be at least 6 characters';
    return '';
  }
}
