import 'dart:io';

import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../utils/storage_keys.dart';

class DeviceIdentifierService {
  static final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  static const _secureStorage = FlutterSecureStorage();
  static final _uuidGenerator = Uuid();
  final Logger _logger = Logger();
  final ApiClient _apiClient = locator<ApiClient>();

  /// Retrieves the platform-specific device identifier.
  /// - For Android, returns Settings.Secure.ANDROID_ID.
  /// - For iOS, returns identifierForVendor (IDFV).
  /// Returns null if the platform is not Android or iOS, or if the ID cannot be fetched.
  Future<String?> getPlatformSpecificIdentifier() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor;
      }
    } catch (e) {
      _logger.e('Failed to get platform specific identifier: $e');
      return null;
    }
    return null;
  }

  String _generateAppSpecificUuid() {
    return _uuidGenerator.v4();
  }

  /// Stores the app-generated UUID securely on the device.
  Future<void> _storeAppGeneratedUuid(String uuid) async {
    try {
      await _secureStorage.write(key: StorageKeys.appGeneratedUuid, value: uuid);
      _logger.i('App-generated UUID stored securely.');
    } catch (e) {
      _logger.e('Failed to store app-generated UUID: $e');
    }
  }

  /// Retrieves the stored app-generated UUID from secure storage.
  /// Returns null if no UUID is found.
  Future<String?> getStoredAppGeneratedUuid() async {
    try {
      final String? uuid = await _secureStorage.read(key: StorageKeys.appGeneratedUuid);
      if (uuid != null && uuid.isNotEmpty) {
        _logger.i('Retrieved stored App-generated UUID.');
        return uuid;
      } else {
        _logger.i('No App-generated UUID found in secure storage.');
        return null;
      }
    } catch (e) {
      _logger.e('Failed to retrieve app-generated UUID: $e');
      return null;
    }
  }

  /// Deletes the stored app-generated UUID.
  /// Useful for unlinking or if a new UUID needs to be generated and stored.
  Future<void> deleteAppGeneratedUuid() async {
    try {
      await _secureStorage.delete(key: StorageKeys.appGeneratedUuid);
      _logger.i('App-generated UUID deleted from secure storage.');
    } catch (e) {
      _logger.e('Failed to delete app-generated UUID: $e');
    }
  }

  Future<String?> getOrGenerateAppSpecificUuid() async {
    String? uuid = await getStoredAppGeneratedUuid();
    if (uuid == null || uuid.isEmpty) {
      uuid = _generateAppSpecificUuid();
      await _storeAppGeneratedUuid(uuid);
      _logger.i('Generated and stored new App-Generated UUID: $uuid');
    }
    return uuid;
  }

  // 
  // Information showed to the user
  //

  Future<String?> getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.utsname.machine;
      }
    } catch (e) {
      _logger.e('Failed to get device name: $e');
      return null;
    }
    return 'Unknown Device'; // Fallback for other platforms or if an error occurs
  }

  Future<String?> getOsVersion() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        return "Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})";
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        return "iOS ${iosInfo.utsname.release}";
      }
    } catch (e) {
      _logger.e('Failed to get OS version: $e');
      return null;
    }
    return 'Unknown OS'; // Fallback
  }
  
  Future<Map<String, String?>> getRegisteredDevice(String? studentIndex) async {
    try {
      final response = await _apiClient.get(
          '${ApiEndpoints.students}/$studentIndex/registered-device'
      );
      final Map<String, String> data = response['data'];
      _logger.i('Successfully fetched registered device for student $studentIndex.');
      return {
        'id': data['device_id'],
        'name': data['device_name'],
        'os': data['device_os'],
      };
    } on ApiException catch (e) {
      _logger.e('API Error on device link request: ${e.message}');
      throw Exception('Failed to submit request: ${e.message}');
    } catch (e) {
      _logger.e('Unknown error on device link request: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> requestDeviceLink(String studentIndex) async {
    final deviceId = await getPlatformSpecificIdentifier();
    final deviceName = await getDeviceName();
    final deviceOs = await getOsVersion();

    if (deviceId == null) {
      throw Exception('Could not get device identifier.');
    }

    final requestBody = {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceOs': deviceOs,
    };

    try {
      await _apiClient.post(
        '${ApiEndpoints.students}/$studentIndex/device-link-request',
        requestBody,
      );
      _logger.i('Successfully sent device link request for student $studentIndex.');
    } on ApiException catch (e) {
      _logger.e('API Error on device link request: ${e.message}');
      throw Exception('Failed to submit request: ${e.message}');
    } catch (e) {
      _logger.e('Unknown error on device link request: $e');
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }
}