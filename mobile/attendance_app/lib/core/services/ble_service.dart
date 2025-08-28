import 'dart:async';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum ProximityLevel { near, medium, far, outOfRange }

enum AttendanceVerificationStatus { pending, verified, failed, timeout }

class PermissionRequestResult {
  final bool success;
  final String message;
  final bool canRetry;
  final bool needsSettingsRedirect;
  final bool needsBluetoothEnable;
  final List<String> deniedPermissions;

  PermissionRequestResult({
    required this.success,
    required this.message,
    this.canRetry = false,
    this.needsSettingsRedirect = false,
    this.needsBluetoothEnable = false,
    this.deniedPermissions = const [],
  });
}

class BeaconDetection {
  final String deviceId;
  final String roomId;
  final int rssi;
  final ProximityLevel proximity;
  final DateTime timestamp;
  final double estimatedDistance;

  BeaconDetection({
    required this.deviceId,
    required this.roomId,
    required this.rssi,
    required this.proximity,
    required this.timestamp,
    required this.estimatedDistance,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'roomId': roomId,
    'rssi': rssi,
    'proximity': proximity.name,
    'timestamp': timestamp.toIso8601String(),
    'estimatedDistance': estimatedDistance,
  };
}

class ProximityAttendanceService {
  static const String finkiBeaconServiceUuid = "A07498CA-AD5B-474E-940D-16F1F759427C";
  static const Duration defaultScanTimeout = Duration(seconds: 10);
  static const Duration verificationTimeout = Duration(seconds: 30);
  static const Duration continuousCheckInterval = Duration(seconds: 5);

  final StreamController<BeaconDetection> _beaconDetectionController = StreamController.broadcast();
  final StreamController<AttendanceVerificationStatus> _verificationStatusController = StreamController.broadcast();

  Stream<BeaconDetection> get beaconDetections => _beaconDetectionController.stream;

  Stream<AttendanceVerificationStatus> get verificationStatus => _verificationStatusController.stream;

  Timer? _continuousVerificationTimer;
  BeaconDetection? _lastValidDetection;

  /// Start comprehensive attendance verification with detailed logging
  Future<void> startAttendanceVerification({required String sessionId, Duration? verificationDuration}) async {
    try {
      _verificationStatusController.add(AttendanceVerificationStatus.pending);

      final duration = verificationDuration ?? verificationTimeout;
      bool verificationPassed = false;
      DateTime startTime = DateTime.now();

      // Start continuous scanning
      await detectBeaconProximity(continuousMode: true);

      // Set up continuous verification timer
      _continuousVerificationTimer = Timer.periodic(continuousCheckInterval, (timer) {
        final elapsed = DateTime.now().difference(startTime);

        if (elapsed > duration) {
          timer.cancel();
          final status =
              verificationPassed ? AttendanceVerificationStatus.verified : AttendanceVerificationStatus.timeout;
          _verificationStatusController.add(status);
          return;
        }

        // Check if we have recent valid detection
        if (_lastValidDetection != null) {
          final timeSinceLastDetection = DateTime.now().difference(_lastValidDetection!.timestamp);

          if (timeSinceLastDetection < const Duration(seconds: 10)) {
            // Student is still in range
            verificationPassed = true;
            if (_lastValidDetection!.proximity == ProximityLevel.near ||
                _lastValidDetection!.proximity == ProximityLevel.medium) {
              // Good proximity, continue verification
            }
          } else {
            // Student might have left the room
            verificationPassed = false;
            _verificationStatusController.add(AttendanceVerificationStatus.failed);
            timer.cancel();
          }
        }
      });
    } catch (e) {
      _verificationStatusController.add(AttendanceVerificationStatus.failed);
      throw Exception('Attendance verification failed: $e');
    }
  }

  /// Enhanced proximity detection with continuous verification
  Future<BeaconDetection?> detectBeaconProximity({Duration? timeout, bool continuousMode = false}) async {
    try {
      print("🔍 Starting beacon proximity detection...");

      // Check permissions first
      if (!await _checkPermissions()) {
        print("❌ Bluetooth permissions not granted");
        throw Exception('Bluetooth permissions not granted');
      }
      print("✅ Bluetooth permissions granted");

      if (!await FlutterBluePlus.isSupported) {
        print("❌ Bluetooth not supported on this device");
        throw Exception('Bluetooth not available on this device');
      }
      print("✅ Bluetooth is supported");

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        print("❌ Bluetooth adapter is off: $adapterState");
        throw Exception('Bluetooth is turned off');
      }
      print("✅ Bluetooth adapter is on");

      final scanTimeout = timeout ?? defaultScanTimeout;
      print("📡 Starting scan for FINKI beacon (timeout: ${scanTimeout.inSeconds}s)");
      print("🎯 Looking for service UUID: $finkiBeaconServiceUuid");

      final completer = Completer<BeaconDetection?>();
      StreamSubscription? scanSubscription;
      int deviceCount = 0;

      // Set scan timeout
      final timeoutTimer = Timer(scanTimeout, () {
        if (!completer.isCompleted) {
          print("⏰ Scan timeout reached after ${scanTimeout.inSeconds} seconds");
          print("📊 Total devices found: $deviceCount");
          scanSubscription?.cancel();
          completer.complete(null);
        }
      });

      // Listen for scan results
      scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          deviceCount++;
          print("📱 Found device: ${result.device.platformName.isNotEmpty ? result.device.platformName : 'Unknown'} (${result.device.remoteId})");
          print("   RSSI: ${result.rssi} dBm");
          print("   Services: ${result.advertisementData.serviceUuids.map((e) => e.toString()).join(', ')}");

          final detection = _processScanResult(result);
          if (detection != null) {
            print("🎯 FINKI beacon detected!");
            print("   Room ID: ${detection.roomId}");
            print("   Proximity: ${detection.proximity.name}");
            print("   Distance: ${detection.estimatedDistance.toStringAsFixed(2)}m");

            _lastValidDetection = detection;
            _beaconDetectionController.add(detection);

            if (!continuousMode && !completer.isCompleted) {
              scanSubscription?.cancel();
              timeoutTimer.cancel();
              completer.complete(detection);
              return;
            }
          }
        }
      });

      // Start scanning
      await FlutterBluePlus.startScan(timeout: scanTimeout, withServices: [Guid(finkiBeaconServiceUuid)]);

      if (continuousMode) {
        return _lastValidDetection;
      } else {
        final result = await completer.future;
        if (result == null) {
          print("❌ No FINKI beacon found during scan");
        }
        return result;
      }
    } catch (e) {
      print("❌ Beacon detection error: $e");
      throw Exception('Beacon detection failed: $e');
    }
  }

  /// Stop continuous verification
  void stopAttendanceVerification() {
    _continuousVerificationTimer?.cancel();
    FlutterBluePlus.stopScan();
  }

  /// Process scan result and extract beacon information
  BeaconDetection? _processScanResult(ScanResult result) {
    try {
      // Check if this is a FINKI beacon
      final hasService = result.advertisementData.serviceUuids.contains(Guid(finkiBeaconServiceUuid));

      if (!hasService) return null;

      final rssi = result.rssi;
      final proximity = _rssiToProximity(rssi);
      final distance = _calculateDistance(rssi, -59); // -59 dBm at 1 meter

      // Extract room information from manufacturer data
      String roomId = "UNKNOWN_ROOM";
      final manufacturerData = result.advertisementData.manufacturerData;

      if (manufacturerData.isNotEmpty) {
        // Parse room ID from manufacturer data
        roomId = _extractRoomIdFromManufacturerData(manufacturerData);
      }

      return BeaconDetection(
        deviceId: result.device.remoteId.toString(),
        roomId: roomId,
        rssi: rssi,
        proximity: proximity,
        timestamp: DateTime.now(),
        estimatedDistance: distance,
      );
    } catch (e) {
      return null;
    }
  }

  /// Convert RSSI to proximity level
  ProximityLevel _rssiToProximity(int rssi) {
    if (rssi > -50) {
      return ProximityLevel.near; // < 1 meter
    } else if (rssi > -70) {
      return ProximityLevel.medium; // 1-3 meters
    } else if (rssi > -85) {
      return ProximityLevel.far; // 3-10 meters
    } else {
      return ProximityLevel.outOfRange; // > 10 meters
    }
  }

  /// Calculate estimated distance from RSSI
  double _calculateDistance(int rssi, int txPower) {
    if (rssi == 0) return -1.0;

    final ratio = (txPower - rssi) / 20.0;
    return pow(10, ratio).toDouble();
  }

  /// Extract room ID from manufacturer data
  String _extractRoomIdFromManufacturerData(Map<int, List<int>> manufacturerData) {
    try {
      // Look for Apple's company ID (0x004C) used in our beacon
      final appleData = manufacturerData[0x004C];
      if (appleData != null && appleData.length >= 18) {
        // Extract room ID bytes (positions 4-19 in our format)
        final roomIdBytes = appleData.sublist(4, 20);
        final roomId = String.fromCharCodes(roomIdBytes).replaceAll('\x00', '');
        return roomId.isNotEmpty ? roomId : "UNKNOWN_ROOM";
      }
    } catch (e) {
      // Fallback parsing
    }
    return "UNKNOWN_ROOM";
  }

  /// Check and request necessary permissions with better user experience
  Future<PermissionRequestResult> checkAndRequestPermissions() async {
    try {
      print("🔍 Checking Bluetooth permissions...");

      // Check if Bluetooth is supported first
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
        Permission.location,
      ];

      List<Permission> deniedPermissions = [];
      List<Permission> permanentlyDeniedPermissions = [];

      // First, check current status of all permissions
      for (final permission in permissions) {
        final status = await permission.status;
        print("📋 Permission ${permission.toString()}: ${status.toString()}");

        if (!status.isGranted) {
          if (status.isPermanentlyDenied) {
            permanentlyDeniedPermissions.add(permission);
          } else {
            deniedPermissions.add(permission);
          }
        }
      }

      // If some permissions are permanently denied, guide user to settings
      if (permanentlyDeniedPermissions.isNotEmpty) {
        return PermissionRequestResult(
          success: false,
          message: "Some permissions were permanently denied. Please enable them in Settings.",
          canRetry: true,
          needsSettingsRedirect: true,
          deniedPermissions: permanentlyDeniedPermissions.map((p) => p.toString()).toList(),
        );
      }

      // Request denied permissions one by one with explanations
      if (deniedPermissions.isNotEmpty) {
        print("📱 Requesting ${deniedPermissions.length} permissions...");

        for (final permission in deniedPermissions) {
          print("🔐 Requesting permission: ${permission.toString()}");
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

      print("✅ All Bluetooth permissions granted and Bluetooth is enabled");
      return PermissionRequestResult(success: true, message: "All permissions granted");

    } catch (e) {
      print("❌ Permission check failed: $e");
      return PermissionRequestResult(
        success: false,
        message: "Failed to check permissions: $e",
        canRetry: true,
      );
    }
  }

  /// Get user-friendly message for denied permissions
  String _getPermissionDeniedMessage(Permission permission) {
    switch (permission) {
      case Permission.bluetooth:
      case Permission.bluetoothScan:
      case Permission.bluetoothConnect:
        return "Bluetooth permission is required to detect classroom beacons for attendance verification.";
      case Permission.bluetoothAdvertise:
        return "Bluetooth advertising permission is needed for professor mode when your phone acts as a beacon.";
      case Permission.location:
        return "Location permission is required by Android/iOS for Bluetooth scanning to work properly.";
      default:
        return "This permission is required for the attendance app to function properly.";
    }
  }

  /// Legacy method - now uses improved permission handling
  Future<bool> _checkPermissions() async {
    final result = await checkAndRequestPermissions();
    return result.success;
  }

  /// Get current proximity status
  String getProximityDescription(ProximityLevel level) {
    switch (level) {
      case ProximityLevel.near:
        return "Very Close (< 1m)";
      case ProximityLevel.medium:
        return "Close (1-3m)";
      case ProximityLevel.far:
        return "Distant (3-10m)";
      case ProximityLevel.outOfRange:
        return "Out of Range (> 10m)";
    }
  }

  /// Get simple proximity string for existing API
  String getSimpleProximity() {
    if (_lastValidDetection == null) return "FAR";

    switch (_lastValidDetection!.proximity) {
      case ProximityLevel.near:
        return "NEAR";
      case ProximityLevel.medium:
        return "MEDIUM";
      case ProximityLevel.far:
        return "FAR";
      case ProximityLevel.outOfRange:
        return "FAR";
    }
  }

  /// Dispose resources
  void dispose() {
    _continuousVerificationTimer?.cancel();
    _beaconDetectionController.close();
    _verificationStatusController.close();
    stopAttendanceVerification();
  }
}

// Legacy compatibility wrapper
class BleService {
  final ProximityAttendanceService _proximityService = ProximityAttendanceService();
  final String finkiBeaconServiceUuid = "A07498CA-AD5B-474E-940D-16F1F759427C";

  Future<String> getProximity() async {
    try {
      // Use longer timeout for better beacon detection
      final detection = await _proximityService.detectBeaconProximity(
        timeout: const Duration(seconds: 30), // Increased from default 10 seconds
      );
      if (detection != null) {
        return _proximityService.getSimpleProximity();
      } else {
        throw Exception('No FINKI beacon detected within scan range. Please ensure the beacon is running and you are close enough to it.');
      }
    } on Exception catch (e) {
      // Re-throw the original exception with more context
      final errorMessage = e.toString();
      if (errorMessage.contains('Bluetooth permissions not granted')) {
        throw Exception('Bluetooth permissions are required. Please enable Bluetooth permissions in your device settings.');
      } else if (errorMessage.contains('Bluetooth not available')) {
        throw Exception('Bluetooth is not available on this device.');
      } else if (errorMessage.contains('Bluetooth is turned off')) {
        throw Exception('Bluetooth is turned off. Please enable Bluetooth in your device settings.');
      } else {
        throw Exception('Beacon scanning failed: ${errorMessage}. Please ensure the beacon is running and transmitting.');
      }
    } catch (e) {
      throw Exception('Unexpected error during beacon detection: $e');
    }
  }

  String _rssiToProximity(int rssi) {
    if (rssi > -70) {
      return "NEAR";
    } else if (rssi > -85) {
      return "MEDIUM";
    } else {
      return "FAR";
    }
  }
}
