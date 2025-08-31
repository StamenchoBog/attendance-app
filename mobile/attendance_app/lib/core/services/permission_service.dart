import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static final Logger _logger = Logger();

  /// Check and request all required permissions for the app
  static Future<bool> requestInitialPermissions(BuildContext context) async {
    _logger.i('Checking initial app permissions...');

    // Get required permissions based on platform and Android API level
    List<Permission> requiredPermissions = await _getRequiredPermissions();

    // Check current permission status
    Map<Permission, PermissionStatus> statuses = await requiredPermissions.request();

    // Track denied permissions
    List<Permission> deniedPermissions = [];
    List<Permission> permanentlyDeniedPermissions = [];

    for (var entry in statuses.entries) {
      if (entry.value.isDenied) {
        deniedPermissions.add(entry.key);
      } else if (entry.value.isPermanentlyDenied) {
        permanentlyDeniedPermissions.add(entry.key);
      }
    }

    // Handle denied permissions
    if (deniedPermissions.isNotEmpty || permanentlyDeniedPermissions.isNotEmpty) {
      _logger.w('Some permissions were denied: ${deniedPermissions.length + permanentlyDeniedPermissions.length}');

      if (permanentlyDeniedPermissions.isNotEmpty) {
        _showPermissionSettingsDialog(context, permanentlyDeniedPermissions);
        return false;
      } else {
        _showPermissionExplanationDialog(context, deniedPermissions);
        return false;
      }
    }

    _logger.i('All required permissions granted successfully');
    return true;
  }

  /// Get the required permissions based on platform and Android API level
  static Future<List<Permission>> _getRequiredPermissions() async {
    List<Permission> requiredPermissions = [];

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      // Always require camera for QR scanning
      requiredPermissions.add(Permission.camera);

      // Bluetooth permissions based on Android version
      if (sdkInt >= 31) {
        // Android 12+
        requiredPermissions.addAll([Permission.bluetoothScan, Permission.bluetoothConnect]);
      } else {
        // Android 11 and below
        requiredPermissions.addAll([
          Permission.bluetooth,
          Permission.locationWhenInUse, // Required for Bluetooth scanning on older Android
        ]);
      }
    } else if (Platform.isIOS) {
      requiredPermissions = [Permission.bluetooth, Permission.camera];
    }

    return requiredPermissions;
  }

  /// Check and request all required permissions for the app
  static Future<bool> requestBluetoothPermissions(BuildContext context) async {
    _logger.i('Checking Bluetooth permissions only...');

    // Get Bluetooth-specific permissions based on platform and Android API level
    List<Permission> requiredPermissions = await _getBluetoothPermissions();

    // Check current permission status
    Map<Permission, PermissionStatus> statuses = await requiredPermissions.request();

    // Track denied permissions
    List<Permission> deniedPermissions = [];
    List<Permission> permanentlyDeniedPermissions = [];

    for (var entry in statuses.entries) {
      if (entry.value.isDenied) {
        deniedPermissions.add(entry.key);
      } else if (entry.value.isPermanentlyDenied) {
        permanentlyDeniedPermissions.add(entry.key);
      }
    }

    // Handle denied permissions
    if (deniedPermissions.isNotEmpty || permanentlyDeniedPermissions.isNotEmpty) {
      _logger.w(
        'Some Bluetooth permissions were denied: ${deniedPermissions.length + permanentlyDeniedPermissions.length}',
      );

      if (permanentlyDeniedPermissions.isNotEmpty) {
        _showPermissionSettingsDialog(context, permanentlyDeniedPermissions);
        return false;
      } else {
        _showPermissionExplanationDialog(context, deniedPermissions);
        return false;
      }
    }

    _logger.i('All required Bluetooth permissions granted successfully');
    return true;
  }

  /// Get the required Bluetooth permissions based on platform and Android API level
  static Future<List<Permission>> _getBluetoothPermissions() async {
    List<Permission> requiredPermissions = [];

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 31) {
        // Android 12+
        requiredPermissions.addAll([Permission.bluetoothScan, Permission.bluetoothConnect]);
      } else {
        // Android 11 and below
        requiredPermissions.addAll([
          Permission.bluetooth,
          Permission.locationWhenInUse, // Required for Bluetooth scanning on older Android
        ]);
      }
    } else if (Platform.isIOS) {
      requiredPermissions = [Permission.bluetooth];
    }

    return requiredPermissions;
  }

  /// Show dialog explaining why permissions are needed (for denied permissions)
  static void _showPermissionExplanationDialog(BuildContext context, List<Permission> deniedPermissions) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This app needs the following permissions to work properly:'),
              const SizedBox(height: 16),
              ...deniedPermissions.map(
                (permission) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(_getPermissionIcon(permission), size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_getPermissionDescription(permission))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Exit app if user refuses permissions
                // You might want to handle this differently
              },
              child: const Text('Not Now'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                requestInitialPermissions(context);
              },
              child: const Text('Grant Permissions'),
            ),
          ],
        );
      },
    );
  }

  /// Show dialog to direct user to settings (for permanently denied permissions)
  static void _showPermissionSettingsDialog(BuildContext context, List<Permission> permanentlyDeniedPermissions) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissions Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Some permissions have been permanently denied. Please enable them in Settings to use the app.',
              ),
              const SizedBox(height: 16),
              ...permanentlyDeniedPermissions.map(
                (permission) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(_getPermissionIcon(permission), size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_getPermissionDescription(permission))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Get icon for permission type
  static IconData _getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.bluetooth:
      case Permission.bluetoothScan:
      case Permission.bluetoothConnect:
        return Icons.bluetooth;
      case Permission.location:
        return Icons.location_on;
      case Permission.camera:
        return Icons.camera_alt;
      default:
        return Icons.security;
    }
  }

  /// Get user-friendly description for permission
  static String _getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.bluetooth:
      case Permission.bluetoothScan:
      case Permission.bluetoothConnect:
        return 'Bluetooth - To detect classroom beacons for attendance';
      case Permission.location:
        return 'Location - Required for Bluetooth scanning functionality';
      case Permission.camera:
        return 'Camera - To scan QR codes for attendance verification';
      default:
        return 'Required for app functionality';
    }
  }

  /// Check if all required permissions are currently granted
  static Future<bool> arePermissionsGranted() async {
    List<Permission> requiredPermissions = await _getRequiredPermissions();

    for (Permission permission in requiredPermissions) {
      if (!await permission.isGranted) {
        return false;
      }
    }

    return true;
  }

  /// Check if only Bluetooth permissions are currently granted
  static Future<bool> areBluetoothPermissionsGranted() async {
    List<Permission> requiredPermissions = await _getBluetoothPermissions();

    for (Permission permission in requiredPermissions) {
      if (!await permission.isGranted) {
        return false;
      }
    }

    return true;
  }
}
