import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';
import '../../data/models/beacon_models.dart';

class BluetoothPermissionManager {
  static final _logger = Logger();
  /// Check and request Bluetooth permissions
  static Future<PermissionRequestResult> checkAndRequestPermissions() async {
    try {
      _logger.i("Checking Bluetooth permissions...");

      if (!await FlutterBluePlus.isSupported) {
        return PermissionRequestResult(
          success: false,
          message: "Bluetooth is not supported on this device",
          canRetry: false,
        );
      }

      final permissions = [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
      ];

      List<Permission> deniedPermissions = [];
      List<Permission> permanentlyDeniedPermissions = [];

      // Check current status of all permissions
      for (final permission in permissions) {
        final status = await permission.status;
        _logger.i("Permission ${permission.toString()}: ${status.toString()}");

        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            permanentlyDeniedPermissions.add(permission);
          } else {
            deniedPermissions.add(permission);
          }
        }
      }

      // Handle permanently denied permissions
      if (permanentlyDeniedPermissions.isNotEmpty) {
        return PermissionRequestResult(
          success: false,
          message: "Some permissions were permanently denied. Please enable them in Settings.",
          canRetry: true,
          needsSettingsRedirect: true,
          deniedPermissions: permanentlyDeniedPermissions.map((p) => p.toString()).toList(),
        );
      }

      // Request denied permissions
      if (deniedPermissions.isNotEmpty) {
        for (final permission in deniedPermissions) {
          _logger.i("Requesting permission: ${permission.toString()}");
          final result = await permission.request();

          if (!result.isGranted) {
            return PermissionRequestResult(
              success: false,
              message: _getPermissionDeniedMessage(permission),
              canRetry: !result.isPermanentlyDenied,
              needsSettingsRedirect: result.isPermanentlyDenied,
              deniedPermissions: [permission.toString()],
            );
          }
        }
      }

      // Check if Bluetooth is enabled
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        return PermissionRequestResult(
          success: false,
          message: "Bluetooth is turned off. Please turn on Bluetooth in your device settings.",
          canRetry: true,
          needsBluetoothEnable: true,
        );
      }
      return PermissionRequestResult(success: true, message: "All permissions granted");
    } catch (e) {
      return PermissionRequestResult(success: false, message: "Failed to check permissions: $e", canRetry: true);
    }
  }

  /// Check if basic Bluetooth permissions are granted (for quick checks)
  static Future<bool> areBasicPermissionsGranted() async {
    try {
      final bluetoothGranted = await Permission.bluetooth.isGranted;
      final bluetoothScanGranted = await Permission.bluetoothScan.isGranted;

      return bluetoothGranted || bluetoothScanGranted;
    } catch (e) {
      _logger.e("Permission check failed: $e");
      return true;
    }
  }

  /// Get user-friendly message for denied permissions
  static String _getPermissionDeniedMessage(Permission permission) {
    switch (permission.value) {
      case 10: // bluetooth
      case 34: // bluetoothScan
      case 36: // bluetoothConnect
        return "Bluetooth permission is required to detect classroom beacons for attendance verification.";
      case 35: // bluetoothAdvertise
        return "Bluetooth advertising permission is needed for professor mode.";
      case 4: // location
        return "Location permission is required by Android/iOS for Bluetooth scanning.";
      default:
        return "This permission is required for the attendance app to function properly.";
    }
  }
}
