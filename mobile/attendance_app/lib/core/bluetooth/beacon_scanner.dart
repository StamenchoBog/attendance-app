import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import '../../data/models/beacon_models.dart';
import 'bluetooth_permission_manager.dart';

class BeaconScanner {
  static const String _serviceUuid = "A07498CA-AD5B-474E-940D-16F1F759427C";
  static const String _characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  // Production configuration
  static const int _maxRetries = 3;
  static const int _minRssiThreshold = -100;
  static const Duration _scanCooldown = Duration(milliseconds: 500);

  static final Logger _logger = Logger();
  DateTime? _lastScanTime;
  bool _isScanning = false;

  Future<BeaconDetection?> scanForBeacon({Duration? timeout}) async {
    if (_isScanning) {
      throw StateError('Scan already in progress');
    }

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        final beacons = await _performScan(timeout: timeout, stopOnFirst: true);
        if (beacons.isNotEmpty) {
          return beacons.first;
        }

        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: 1000 * attempt));
        }
      } catch (e) {
        if (attempt == _maxRetries) rethrow;
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    return null;
  }

  Future<List<BeaconDetection>> scanForMultipleBeacons({Duration? timeout}) async {
    if (_isScanning) {
      throw StateError('Scan already in progress');
    }

    return await _performScan(timeout: timeout, stopOnFirst: false);
  }

  Future<List<BeaconDetection>> _performScan({Duration? timeout, required bool stopOnFirst}) async {
    // Rate limiting
    if (_lastScanTime != null) {
      final timeSinceLastScan = DateTime.now().difference(_lastScanTime!);
      if (timeSinceLastScan < _scanCooldown) {
        await Future.delayed(_scanCooldown - timeSinceLastScan);
      }
    }

    _isScanning = true;
    _lastScanTime = DateTime.now();

    try {
      await _validateBluetooth();

      final scanTimeout = timeout ?? AppConstants.bluetoothScanTimeout;
      final detectedBeacons = <BeaconDetection>[];
      final seenDeviceIds = <String>{};

      final completer = Completer<List<BeaconDetection>>();
      StreamSubscription<List<ScanResult>>? subscription;
      Timer? timeoutTimer;

      timeoutTimer = Timer(scanTimeout, () {
        if (!completer.isCompleted) {
          _cleanup(subscription, timeoutTimer);
          completer.complete(detectedBeacons);
        }
      });

      subscription = FlutterBluePlus.scanResults.listen(
        (results) {
          for (final result in results) {
            if (completer.isCompleted) break;

            final deviceId = result.device.remoteId.toString();
            if (seenDeviceIds.contains(deviceId)) continue;

            final detection = _parseBeaconData(result);
            if (detection != null && _isValidDetection(detection)) {
              seenDeviceIds.add(deviceId);
              detectedBeacons.add(detection);

              if (stopOnFirst) {
                _cleanup(subscription, timeoutTimer);
                completer.complete(detectedBeacons);
                return;
              }
            }
          }
        },
        onError: (error) {
          if (!completer.isCompleted) {
            _cleanup(subscription, timeoutTimer);
            completer.completeError(error);
          }
        },
      );

      try {
        await FlutterBluePlus.startScan(timeout: scanTimeout, withServices: [Guid(_serviceUuid)]);
      } catch (e) {
        _cleanup(subscription, timeoutTimer);
        throw Exception('Failed to start BLE scan: $e');
      }

      final result = await completer.future;
      await FlutterBluePlus.stopScan();

      return result;
    } catch (e) {
      _logger.e('Error in beacon scanning: $e');
      rethrow;
    } finally {
      _isScanning = false;
    }
  }

  Future<void> _validateBluetooth() async {
    if (!await BluetoothPermissionManager.areBasicPermissionsGranted()) {
      throw Exception('Bluetooth permissions required. Please grant permissions in Settings.');
    }

    if (!await FlutterBluePlus.isSupported) {
      throw Exception('Bluetooth Low Energy not supported on this device.');
    }

    final adapterState = await FlutterBluePlus.adapterState.first;
    switch (adapterState) {
      case BluetoothAdapterState.off:
        throw Exception('Bluetooth is turned off. Please enable Bluetooth.');
      case BluetoothAdapterState.unavailable:
        throw Exception('Bluetooth adapter unavailable.');
      case BluetoothAdapterState.unauthorized:
        throw Exception('Bluetooth access unauthorized.');
      case BluetoothAdapterState.unknown:
        throw Exception('Bluetooth state unknown.');
      case BluetoothAdapterState.turningOn:
        await _waitForBluetoothState(BluetoothAdapterState.on, timeout: const Duration(seconds: 10));
      case BluetoothAdapterState.turningOff:
        throw Exception('Bluetooth is turning off. Please wait and try again.');
      case BluetoothAdapterState.on:
        break;
    }
  }

  /// Wait for Bluetooth to reach a specific state
  Future<void> _waitForBluetoothState(BluetoothAdapterState targetState, {required Duration timeout}) async {
    final startTime = DateTime.now();

    await for (final state in FlutterBluePlus.adapterState) {
      if (state == targetState) {
        return; // Target state reached
      }

      if (state == BluetoothAdapterState.off) {
        throw Exception('Bluetooth was turned off while waiting.');
      }

      if (DateTime.now().difference(startTime) > timeout) {
        throw Exception('Timeout waiting for Bluetooth to turn on. Please enable Bluetooth manually.');
      }

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Clean up resources safely
  void _cleanup(StreamSubscription? subscription, Timer? timer) {
    try {
      subscription?.cancel();
      timer?.cancel();
      FlutterBluePlus.stopScan();
    } catch (e) {
      // Silently handle cleanup errors in production
    }
  }

  /// Parse beacon data with enhanced validation
  BeaconDetection? _parseBeaconData(ScanResult result) {
    try {
      if (result.rssi < _minRssiThreshold) return null;

      // Device validation
      final bluetoothId = result.device.remoteId.toString();
      if (bluetoothId.isEmpty) return null;

      String beaconType = "UNKNOWN";
      String roomId = "UNKNOWN";
      String deviceId = "UNKNOWN";
      int txPower = -59;

      // Parse FINKI beacons
      if (result.advertisementData.serviceUuids.contains(Guid(_serviceUuid))) {
        beaconType = "DEDICATED_BEACON";
        roomId = _extractRoomData(result) ?? "UNKNOWN";
        deviceId = _extractBeaconId(result) ?? bluetoothId; // Use beacon ID from data, fallback to Bluetooth ID
        txPower = _extractTxPower(result) ?? -59;

        // Validate extracted data
        if (roomId == "UNKNOWN" || roomId.isEmpty) {
          return null;
        }
      } else {
        // Handle other beacon types
        final platformName = result.device.platformName;
        if (platformName.contains("Professor")) {
          beaconType = "PROFESSOR_PHONE";
          roomId = _extractRoomFromDeviceName(platformName);
          deviceId = platformName;
        } else if (platformName.contains("FINKI")) {
          beaconType = "GENERIC_DEVICE";
          roomId = _extractRoomFromDeviceName(platformName);
          deviceId = platformName;
        } else {
          return null;
        }

        if (roomId == "UNKNOWN") return null;
      }

      return BeaconDetection(
        deviceId: deviceId,
        roomId: roomId.toUpperCase(),
        rssi: result.rssi,
        proximity: _calculateProximity(result.rssi),
        timestamp: DateTime.now(),
        estimatedDistance: _calculateDistance(result.rssi, txPower),
        beaconType: beaconType,
      );
    } catch (e) {
      _logger.e('Error parsing beacon data: $e');
      return null;
    }
  }

  /// Validate detection quality
  bool _isValidDetection(BeaconDetection detection) {
    // Room ID validation
    if (detection.roomId.isEmpty || detection.roomId == "UNKNOWN") {
      return false;
    }

    // Distance validation
    if (detection.estimatedDistance < 0 || detection.estimatedDistance > 100) {
      return false;
    }

    // Beacon type validation
    if (!["DEDICATED_BEACON", "PROFESSOR_PHONE", "GENERIC_DEVICE"].contains(detection.beaconType)) {
      return false;
    }

    return true;
  }

  /// Extract room ID from beacon data with fallback strategies
  String? _extractRoomData(ScanResult result) {
    if (result.advertisementData.manufacturerData.isEmpty) {
      return _extractRoomFromDeviceName(result.device.platformName);
    }

    final data = result.advertisementData.manufacturerData.values.first;

    // Try binary format first
    if (data.length >= 40) {
      final roomId = _parseString(data, 0, 8);
      if (_isValidRoomId(roomId)) return roomId;
    }

    // JSON fallback
    try {
      final jsonData = String.fromCharCodes(data);
      final parsed = jsonDecode(jsonData);
      final roomId = parsed['room_id']?.toString();
      if (roomId != null && _isValidRoomId(roomId)) return roomId;
    } catch (_) {}

    // Device name fallback
    return _extractRoomFromDeviceName(result.device.platformName);
  }

  /// Extract room from device name
  String _extractRoomFromDeviceName(String deviceName) {
    final parts = deviceName.split("-");
    if (parts.length >= 3) {
      final roomId = parts[2];
      return _isValidRoomId(roomId) ? roomId : "UNKNOWN";
    }
    return "UNKNOWN";
  }

  /// Validate room ID format
  bool _isValidRoomId(String roomId) {
    if (roomId.isEmpty || roomId == "UNKNOWN") return false;

    // Basic room ID validation (alphanumeric, max 8 chars)
    final regex = RegExp(r'^[A-Z0-9]{1,8}$', caseSensitive: false);
    return regex.hasMatch(roomId);
  }

  /// Extract TX power with validation
  int? _extractTxPower(ScanResult result) {
    if (result.advertisementData.manufacturerData.isEmpty) return null;

    final data = result.advertisementData.manufacturerData.values.first;

    // Binary format
    if (data.length >= 26) {
      try {
        final buffer = Uint8List.fromList(data);
        final byteData = ByteData.sublistView(buffer);
        final txPower = byteData.getInt8(25);

        // Validate TX power range (-40 to +20 dBm)
        if (txPower >= -40 && txPower <= 20) {
          return txPower;
        }
      } catch (_) {}
    }

    // JSON fallback
    try {
      final jsonData = String.fromCharCodes(data);
      final parsed = jsonDecode(jsonData);
      final txPower = parsed['tx_power']?.toInt();
      if (txPower != null && txPower >= -40 && txPower <= 20) {
        return txPower;
      }
    } catch (_) {}

    return null;
  }

  /// Extract beacon device ID from beacon data
  String? _extractBeaconId(ScanResult result) {
    if (result.advertisementData.manufacturerData.isEmpty) {
      return _extractBeaconIdFromDeviceName(result.device.platformName);
    }

    final data = result.advertisementData.manufacturerData.values.first;

    // Try binary format first
    if (data.length >= 40) {
      final beaconId = _parseString(data, 16, 8); // Beacon ID is at offset 16
      if (beaconId.isNotEmpty && beaconId != "UNKNOWN") return beaconId;
    }

    // JSON fallback
    try {
      final jsonData = String.fromCharCodes(data);
      final parsed = jsonDecode(jsonData);
      final beaconId = parsed['beacon_id']?.toString();
      if (beaconId != null && beaconId.isNotEmpty) return beaconId;
    } catch (_) {}

    // Device name fallback
    return _extractBeaconIdFromDeviceName(result.device.platformName);
  }

  /// Extract beacon ID from device name
  String? _extractBeaconIdFromDeviceName(String deviceName) {
    if (deviceName.contains("FINKI")) {
      // Try to find a pattern like BCN01, BEACON01, etc.
      final beaconPattern = RegExp(r'(BCN\d+|BEACON\d+)', caseSensitive: false);
      final match = beaconPattern.firstMatch(deviceName);
      if (match != null) {
        return match.group(1)?.toUpperCase();
      }

      // Fallback: use the full device name if it's reasonably short
      if (deviceName.length <= 20) {
        return deviceName;
      }
    }

    return null;
  }

  /// Parse string with enhanced validation
  String _parseString(List<int> data, int offset, int maxLength) {
    final validChars = <int>[];
    final end = (offset + maxLength).clamp(0, data.length);

    for (int i = offset; i < end; i++) {
      final byte = data[i];
      if (byte == 0) break;

      // Allow alphanumeric and basic punctuation
      if ((byte >= 48 && byte <= 57) ||
          (byte >= 65 && byte <= 90) ||
          (byte >= 97 && byte <= 122) ||
          byte == 45 ||
          byte == 95) {
        // - and _
        validChars.add(byte);
      }
    }

    return String.fromCharCodes(validChars).trim();
  }

  /// Calculate proximity with production thresholds
  ProximityLevel _calculateProximity(int rssi) {
    // Production-tested thresholds
    if (rssi > -45) return ProximityLevel.near; // 0-2m
    if (rssi > -65) return ProximityLevel.medium; // 2-8m
    if (rssi > -85) return ProximityLevel.far; // 8-20m
    return ProximityLevel.outOfRange; // >20m
  }

  /// Calculate distance with improved algorithm
  double _calculateDistance(int rssi, int txPower) {
    if (rssi == 0 || rssi > 0) return -1.0;
    if (rssi > txPower) return 0.3; // Minimum distance

    // Enhanced indoor path loss model
    const double pathLossExponent = 2.2; // Optimized for classroom environments
    const double environmentFactor = 1.5; // Account for obstacles

    final double ratio = (txPower - rssi) / (10.0 * pathLossExponent);
    final double distance = pow(10, ratio) * environmentFactor;

    return distance.clamp(0.1, 50.0);
  }

  /// Convert proximity level to API string
  String getProximityLevelString(ProximityLevel level) {
    return switch (level) {
      ProximityLevel.near => "NEAR",
      ProximityLevel.medium => "MEDIUM",
      ProximityLevel.far => "FAR",
      ProximityLevel.outOfRange => "OUT_OF_RANGE",
    };
  }

  /// Convert BeaconDetection to API format with validation
  Map<String, dynamic> toProximityDetectionDTO({
    required BeaconDetection detection,
    required String studentIndex,
    required String sessionToken,
  }) {
    // Validate inputs
    if (studentIndex.isEmpty) throw ArgumentError('Student index cannot be empty');
    if (sessionToken.isEmpty) throw ArgumentError('Session token cannot be empty');
    if (!_isValidDetection(detection)) throw ArgumentError('Invalid beacon detection');

    return {
      'studentIndex': studentIndex,
      'sessionToken': sessionToken,
      'beaconDeviceId': detection.deviceId,
      'detectedRoomId': detection.roomId,
      'rssi': detection.rssi,
      'proximityLevel': getProximityLevelString(detection.proximity),
      'estimatedDistance': double.parse(detection.estimatedDistance.toStringAsFixed(2)),
      'detectionTimestamp': detection.timestamp.toUtc().toIso8601String(),
      'beaconType': detection.beaconType,
    };
  }

  /// Get scanner status for monitoring
  Map<String, dynamic> getStatus() {
    return {
      'isScanning': _isScanning,
      'lastScanTime': _lastScanTime?.toIso8601String(),
      'serviceUuid': _serviceUuid,
      'minRssiThreshold': _minRssiThreshold,
    };
  }

  /// Reset scanner state (for testing/debugging)
  void reset() {
    _isScanning = false;
    _lastScanTime = null;
  }
}
