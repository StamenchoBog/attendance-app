import 'beacon_models.dart';

class ProximityDetectionRequest {
  final String studentIndex;
  final String sessionToken;
  final String beaconDeviceId;
  final String detectedRoomId;
  final int rssi;
  final String proximityLevel; // NEAR, MEDIUM, FAR, OUT_OF_RANGE
  final double estimatedDistance;
  final DateTime detectionTimestamp;
  final String beaconType; // DEDICATED_BEACON, PROFESSOR_PHONE

  ProximityDetectionRequest({
    required this.studentIndex,
    required this.sessionToken,
    required this.beaconDeviceId,
    required this.detectedRoomId,
    required this.rssi,
    required this.proximityLevel,
    required this.estimatedDistance,
    required this.detectionTimestamp,
    required this.beaconType,
  });

  Map<String, dynamic> toJson() => {
    'studentIndex': studentIndex,
    'sessionToken': sessionToken,
    'beaconDeviceId': beaconDeviceId,
    'detectedRoomId': detectedRoomId,
    'rssi': rssi,
    'proximityLevel': proximityLevel,
    'estimatedDistance': estimatedDistance,
    'detectionTimestamp': detectionTimestamp.toIso8601String(),
    'beaconType': beaconType,
  };
}

class ProximityVerificationRequest {
  final String studentIndex;
  final String sessionToken;
  final int? attendanceId;
  final String expectedRoomId;
  final int verificationDurationSeconds;
  final List<ProximityDetectionRequest> proximityDetections;

  ProximityVerificationRequest({
    required this.studentIndex,
    required this.sessionToken,
    this.attendanceId,
    required this.expectedRoomId,
    required this.verificationDurationSeconds,
    required this.proximityDetections,
  });

  Map<String, dynamic> toJson() => {
    'studentIndex': studentIndex,
    'sessionToken': sessionToken,
    'attendanceId': attendanceId,
    'expectedRoomId': expectedRoomId,
    'verificationDurationSeconds': verificationDurationSeconds,
    'proximityDetections': proximityDetections.map((e) => e.toJson()).toList(),
  };
}

class ProximityVerificationResponse {
  final bool verificationSuccess;
  final String verificationStatus; // SUCCESS, FAILED, TIMEOUT, WRONG_ROOM
  final String detectedRoomId;
  final String expectedRoomId;
  final double averageDistance;
  final int totalDetections;
  final int validDetections;
  final DateTime verificationStartTime;
  final DateTime verificationEndTime;
  final int actualDurationSeconds;
  final String? failureReason;

  ProximityVerificationResponse({
    required this.verificationSuccess,
    required this.verificationStatus,
    required this.detectedRoomId,
    required this.expectedRoomId,
    required this.averageDistance,
    required this.totalDetections,
    required this.validDetections,
    required this.verificationStartTime,
    required this.verificationEndTime,
    required this.actualDurationSeconds,
    this.failureReason,
  });

  factory ProximityVerificationResponse.fromJson(Map<String, dynamic> json) {
    return ProximityVerificationResponse(
      verificationSuccess: json['verificationSuccess'] ?? false,
      verificationStatus: json['verificationStatus'] ?? '',
      detectedRoomId: json['detectedRoomId'] ?? '',
      expectedRoomId: json['expectedRoomId'] ?? '',
      averageDistance: (json['averageDistance'] ?? 0.0).toDouble(),
      totalDetections: json['totalDetections'] ?? 0,
      validDetections: json['validDetections'] ?? 0,
      verificationStartTime: DateTime.parse(json['verificationStartTime']),
      verificationEndTime: DateTime.parse(json['verificationEndTime']),
      actualDurationSeconds: json['actualDurationSeconds'] ?? 0,
      failureReason: json['failureReason'],
    );
  }
}

class RoomProximityAnalytics {
  final String roomId;
  final int totalVerifications;
  final int successfulVerifications;
  final double averageDistance;
  final List<ProximityVerificationLog> verificationLogs;

  RoomProximityAnalytics({
    required this.roomId,
    required this.totalVerifications,
    required this.successfulVerifications,
    required this.averageDistance,
    required this.verificationLogs,
  });

  factory RoomProximityAnalytics.fromJson(Map<String, dynamic> json) {
    return RoomProximityAnalytics(
      roomId: json['roomId'] ?? '',
      totalVerifications: json['totalVerifications'] ?? 0,
      successfulVerifications: json['successfulVerifications'] ?? 0,
      averageDistance: (json['averageDistance'] ?? 0.0).toDouble(),
      verificationLogs:
          (json['verificationLogs'] as List<dynamic>? ?? []).map((e) => ProximityVerificationLog.fromJson(e)).toList(),
    );
  }

  double get successRate => totalVerifications > 0 ? (successfulVerifications / totalVerifications) * 100 : 0.0;
}

class ProximityVerificationLog {
  final int id;
  final String studentIndex;
  final String? beaconDeviceId;
  final String? detectedRoomId;
  final String? expectedRoomId;
  final int? rssi;
  final String? proximityLevel;
  final double? estimatedDistance;
  final DateTime verificationTimestamp;
  final String verificationStatus;
  final int? verificationDurationSeconds;
  final String? beaconType;

  ProximityVerificationLog({
    required this.id,
    required this.studentIndex,
    this.beaconDeviceId,
    this.detectedRoomId,
    this.expectedRoomId,
    this.rssi,
    this.proximityLevel,
    this.estimatedDistance,
    required this.verificationTimestamp,
    required this.verificationStatus,
    this.verificationDurationSeconds,
    this.beaconType,
  });

  factory ProximityVerificationLog.fromJson(Map<String, dynamic> json) {
    return ProximityVerificationLog(
      id: json['id'] ?? 0,
      studentIndex: json['studentIndex'] ?? '',
      beaconDeviceId: json['beaconDeviceId'],
      detectedRoomId: json['detectedRoomId'],
      expectedRoomId: json['expectedRoomId'],
      rssi: json['rssi'],
      proximityLevel: json['proximityLevel'],
      estimatedDistance: json['estimatedDistance']?.toDouble(),
      verificationTimestamp: DateTime.parse(json['verificationTimestamp']),
      verificationStatus: json['verificationStatus'] ?? '',
      verificationDurationSeconds: json['verificationDurationSeconds'],
      beaconType: json['beaconType'],
    );
  }
}

/// Data Transfer Object for proximity detection data, matching the server-side DTO
class ProximityDetectionDTO {
  final String studentIndex;
  final String sessionToken;
  final String beaconDeviceId;
  final String detectedRoomId;
  final int rssi;
  final String proximityLevel; // NEAR, MEDIUM, FAR, OUT_OF_RANGE
  final double estimatedDistance;
  final DateTime detectionTimestamp;
  final String beaconType; // DEDICATED_BEACON, PROFESSOR_PHONE

  ProximityDetectionDTO({
    required this.studentIndex,
    required this.sessionToken,
    required this.beaconDeviceId,
    required this.detectedRoomId,
    required this.rssi,
    required this.proximityLevel,
    required this.estimatedDistance,
    required this.detectionTimestamp,
    required this.beaconType,
  });

  /// Convert BeaconDetection from the BLE service to ProximityDetectionDTO
  factory ProximityDetectionDTO.fromBeaconDetection({
    required BeaconDetection detection,
    required String studentIndex,
    required String sessionToken,
  }) {
    return ProximityDetectionDTO(
      studentIndex: studentIndex,
      sessionToken: sessionToken,
      beaconDeviceId: detection.deviceId,
      detectedRoomId: detection.roomId,
      rssi: detection.rssi,
      proximityLevel: detection.proximity.name.toUpperCase(),
      estimatedDistance: detection.estimatedDistance,
      detectionTimestamp: detection.timestamp,
      beaconType: 'DEDICATED_BEACON', // Default type, can be overridden if needed
    );
  }

  Map<String, dynamic> toJson() => {
    'studentIndex': studentIndex,
    'sessionToken': sessionToken,
    'beaconDeviceId': beaconDeviceId,
    'detectedRoomId': detectedRoomId,
    'rssi': rssi,
    'proximityLevel': proximityLevel,
    'estimatedDistance': estimatedDistance,
    'detectionTimestamp': detectionTimestamp.toIso8601String(),
    'beaconType': beaconType,
  };
}
