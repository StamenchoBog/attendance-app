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
  final String beaconType;

  BeaconDetection({
    required this.deviceId,
    required this.roomId,
    required this.rssi,
    required this.proximity,
    required this.timestamp,
    required this.estimatedDistance,
    required this.beaconType,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'roomId': roomId,
    'rssi': rssi,
    'proximity': proximity.name,
    'timestamp': timestamp.toIso8601String(),
    'estimatedDistance': estimatedDistance,
    'beaconType': beaconType,
  };
}
