import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logger/logger.dart';
import '../../data/models/beacon_models.dart';
import '../../data/models/proximity_verification_models.dart';
import 'ble_service.dart';

/// Service for proximity-based attendance verification workflow
class ProximityAttendanceService {
  final BleService _bleService = BleService();
  static final Logger _logger = Logger();

  // Verification configuration
  static const Duration defaultVerificationDuration = Duration(minutes: 2);
  static const Duration continuousDetectionInterval = Duration(seconds: 3);
  static const int minimumDetectionsRequired = 3;
  static const double consistencyThreshold = 0.7; // 70% of detections must be consistent

  Timer? _continuousVerificationTimer;

  final List<BeaconDetection> _detectionHistory = [];
  final StreamController<BeaconDetection> _beaconDetectionController = StreamController.broadcast();
  final StreamController<AttendanceVerificationStatus> _verificationStatusController = StreamController.broadcast();

  // Public streams for UI updates
  Stream<BeaconDetection> get beaconDetections => _beaconDetectionController.stream;

  Stream<AttendanceVerificationStatus> get verificationStatus => _verificationStatusController.stream;

  BeaconDetection? _lastValidDetection;

  /// Start comprehensive attendance verification with detailed logging
  Future<void> startAttendanceVerification({required String sessionId, Duration? verificationDuration}) async {
    try {
      _verificationStatusController.add(AttendanceVerificationStatus.pendingVerification);

      final duration = verificationDuration ?? defaultVerificationDuration;
      bool verificationPassed = false;
      DateTime startTime = DateTime.now();

      // Start continuous scanning
      await detectBeaconProximity(continuousMode: true);

      // Set up continuous verification timer
      _continuousVerificationTimer = Timer.periodic(continuousDetectionInterval, (timer) {
        final elapsed = DateTime.now().difference(startTime);

        if (elapsed > duration) {
          timer.cancel();
          final status =
              verificationPassed ? AttendanceVerificationStatus.present : AttendanceVerificationStatus.timeout;
          _verificationStatusController.add(status);
          return;
        }

        // Check if we have recent valid detection
        if (_lastValidDetection != null) {
          final timeSinceLastDetection = DateTime.now().difference(_lastValidDetection!.timestamp);

          if (timeSinceLastDetection < const Duration(seconds: 10)) {
            verificationPassed = true;
            if (_lastValidDetection!.proximity == ProximityLevel.near ||
                _lastValidDetection!.proximity == ProximityLevel.medium) {
              // Good proximity, continue verification
            }
          } else {
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

  /// Enhanced proximity detection with better beacon format support
  Future<BeaconDetection?> detectBeaconProximity({bool continuousMode = false}) async {
    try {
      final detection = await _bleService.detectBeaconProximity();

      if (detection != null) {
        _detectionHistory.add(detection);
        _lastValidDetection = detection;
        _beaconDetectionController.add(detection);
      }

      return detection;
    } catch (e) {
      _logger.e("ProximityAttendanceService detection error: $e");
      throw Exception('Proximity detection failed: $e');
    }
  }

  /// Start comprehensive proximity verification workflow using existing models
  Future<ProximityVerificationResponse> startVerificationWorkflow({
    required String sessionToken,
    required String studentIndex,
    required String deviceId,
    String? expectedRoomId,
    Duration? verificationDuration,
  }) async {
    _logger.i("🚀 Starting proximity verification workflow");
    _logger.i("   Session: $sessionToken");
    _logger.i("   Student: $studentIndex");
    _logger.i("   Expected Room: ${expectedRoomId ?? 'Any'}");

    _detectionHistory.clear();
    final duration = verificationDuration ?? defaultVerificationDuration;
    final startTime = DateTime.now();

    try {
      // Step 1: Initial beacon detection
      final initialDetection = await _bleService.detectBeaconProximity(timeout: const Duration(seconds: 30));

      if (initialDetection == null) {
        return ProximityVerificationResponse(
          verificationSuccess: false,
          verificationStatus: 'FAILED',
          detectedRoomId: '',
          expectedRoomId: expectedRoomId ?? '',
          averageDistance: 0.0,
          totalDetections: 0,
          validDetections: 0,
          verificationStartTime: startTime,
          verificationEndTime: DateTime.now(),
          actualDurationSeconds: DateTime.now().difference(startTime).inSeconds,
          failureReason: "No beacon detected. Please ensure you are in the classroom.",
        );
      }

      _detectionHistory.add(initialDetection);
      _logger.i("Initial beacon detected: ${initialDetection.roomId}");

      // Step 2: Validate room if expected room is provided
      if (expectedRoomId != null && !_isRoomMatch(initialDetection.roomId, expectedRoomId)) {
        return ProximityVerificationResponse(
          verificationSuccess: false,
          verificationStatus: 'WRONG_ROOM',
          detectedRoomId: initialDetection.roomId,
          expectedRoomId: expectedRoomId,
          averageDistance: initialDetection.estimatedDistance,
          totalDetections: 1,
          validDetections: 0,
          verificationStartTime: startTime,
          verificationEndTime: DateTime.now(),
          actualDurationSeconds: DateTime.now().difference(startTime).inSeconds,
          failureReason: "Wrong classroom detected. Expected: $expectedRoomId, Found: ${initialDetection.roomId}",
        );
      }

      // Step 3: Continuous verification for the specified duration
      var lastDetectionTime = DateTime.now();

      // Set up continuous detection
      while (DateTime.now().difference(startTime) < duration) {
        await Future.delayed(continuousDetectionInterval);

        try {
          final detection = await _bleService.detectBeaconProximity(timeout: const Duration(seconds: 5));

          if (detection != null) {
            _detectionHistory.add(detection);
            lastDetectionTime = DateTime.now();
          } else {
            // Check if we've lost connection for too long
            final timeSinceLastDetection = DateTime.now().difference(lastDetectionTime);
            if (timeSinceLastDetection > const Duration(seconds: 30)) {
              return ProximityVerificationResponse(
                verificationSuccess: false,
                verificationStatus: 'OUT_OF_RANGE',
                detectedRoomId: initialDetection.roomId,
                expectedRoomId: expectedRoomId ?? '',
                averageDistance: _calculateAverageDistance(),
                totalDetections: _detectionHistory.length,
                validDetections: _detectionHistory.length,
                verificationStartTime: startTime,
                verificationEndTime: DateTime.now(),
                actualDurationSeconds: DateTime.now().difference(startTime).inSeconds,
                failureReason: "Lost connection to classroom beacon. You may have left the room.",
              );
            }
          }
        } catch (e) {
          _logger.w("⚠️ Error during continuous detection: $e");
          // Continue verification even if individual detections fail
        }
      }

      // Step 4: Evaluate verification result
      return _evaluateVerificationWithResponse(sessionToken, studentIndex, deviceId, startTime, expectedRoomId);
    } catch (e, stackTrace) {
      _logger.e("Verification workflow error: $e", error: e, stackTrace: stackTrace);
      return ProximityVerificationResponse(
        verificationSuccess: false,
        verificationStatus: 'FAILED',
        detectedRoomId: '',
        expectedRoomId: expectedRoomId ?? '',
        averageDistance: 0.0,
        totalDetections: 0,
        validDetections: 0,
        verificationStartTime: startTime,
        verificationEndTime: DateTime.now(),
        actualDurationSeconds: DateTime.now().difference(startTime).inSeconds,
        failureReason: "Verification failed: ${e.toString()}",
      );
    }
  }

  /// Evaluate the collected detections and return ProximityVerificationResponse
  ProximityVerificationResponse _evaluateVerificationWithResponse(
    String sessionToken,
    String studentIndex,
    String deviceId,
    DateTime startTime,
    String? expectedRoomId,
  ) {
    _logger.i("📊 Evaluating verification with ${_detectionHistory.length} detections");

    final endTime = DateTime.now();
    final actualDuration = endTime.difference(startTime).inSeconds;

    if (_detectionHistory.isEmpty) {
      return ProximityVerificationResponse(
        verificationSuccess: false,
        verificationStatus: 'FAILED',
        detectedRoomId: '',
        expectedRoomId: expectedRoomId ?? '',
        averageDistance: 0.0,
        totalDetections: 0,
        validDetections: 0,
        verificationStartTime: startTime,
        verificationEndTime: endTime,
        actualDurationSeconds: actualDuration,
        failureReason: "No beacon detections recorded during verification",
      );
    }

    // Analyze detection consistency
    final roomCounts = <String, int>{};
    double totalDistance = 0;
    int validDetections = 0;

    for (final detection in _detectionHistory) {
      roomCounts[detection.roomId] = (roomCounts[detection.roomId] ?? 0) + 1;
      totalDistance += detection.estimatedDistance;

      // Count as valid if proximity is reasonable
      if (detection.proximity == ProximityLevel.near ||
          detection.proximity == ProximityLevel.medium ||
          detection.proximity == ProximityLevel.far) {
        validDetections++;
      }
    }

    // Find most detected room
    final mostDetectedRoom = roomCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final roomConsistency = roomCounts[mostDetectedRoom]! / _detectionHistory.length;

    // Calculate average distance
    final averageDistance = totalDistance / _detectionHistory.length;

    // Determine verification status
    String status;
    String? failureReason;
    bool success = false;

    if (_detectionHistory.length < minimumDetectionsRequired) {
      status = 'INSUFFICIENT';
      failureReason =
          "Insufficient beacon detections for reliable verification (${_detectionHistory.length}/$minimumDetectionsRequired)";
    } else if (roomConsistency < consistencyThreshold) {
      status = 'INCONSISTENT';
      failureReason = "Inconsistent room detections. Room consistency: ${(roomConsistency * 100).toStringAsFixed(1)}%";
    } else if (averageDistance > 50) {
      status = 'TOO_FAR';
      failureReason =
          "Average distance too far (${averageDistance.toStringAsFixed(1)}m). Please move closer to the beacon.";
    } else if (validDetections < (_detectionHistory.length * 0.8)) {
      status = 'LOW_QUALITY';
      failureReason = "Too many out-of-range detections. Signal quality too low.";
    } else {
      success = true;
      status = 'SUCCESS';
    }

    return ProximityVerificationResponse(
      verificationSuccess: success,
      verificationStatus: status,
      detectedRoomId: mostDetectedRoom,
      expectedRoomId: expectedRoomId ?? '',
      averageDistance: averageDistance,
      totalDetections: _detectionHistory.length,
      validDetections: validDetections,
      verificationStartTime: startTime,
      verificationEndTime: endTime,
      actualDurationSeconds: actualDuration,
      failureReason: failureReason,
    );
  }

  /// Calculate average distance from all detections
  double _calculateAverageDistance() {
    if (_detectionHistory.isEmpty) return 0.0;

    double totalDistance = 0;
    for (final detection in _detectionHistory) {
      totalDistance += detection.estimatedDistance;
    }
    return totalDistance / _detectionHistory.length;
  }

  /// Check if detected room matches expected room (with fuzzy matching)
  bool _isRoomMatch(String detectedRoom, String expectedRoom) {
    // Exact match
    if (detectedRoom == expectedRoom) return true;

    // Normalize and compare (remove spaces, case insensitive)
    final normalizedDetected = detectedRoom.replaceAll(' ', '').toLowerCase();
    final normalizedExpected = expectedRoom.replaceAll(' ', '').toLowerCase();

    if (normalizedDetected == normalizedExpected) return true;

    // Check if one contains the other (for partial matches)
    if (normalizedDetected.contains(normalizedExpected) || normalizedExpected.contains(normalizedDetected)) return true;

    return false;
  }

  /// Stop continuous verification
  void stopAttendanceVerification() {
    _continuousVerificationTimer?.cancel();
    FlutterBluePlus.stopScan();
  }

  List<ProximityDetectionRequest> getProximityDetectionsForApi({
    required String sessionToken,
    required String studentIndex,
  }) {
    return _detectionHistory
        .map(
          (detection) => ProximityDetectionRequest(
            studentIndex: studentIndex,
            sessionToken: sessionToken,
            beaconDeviceId: detection.deviceId,
            detectedRoomId: detection.roomId,
            rssi: detection.rssi,
            proximityLevel: detection.proximity.name.toUpperCase(),
            estimatedDistance: detection.estimatedDistance,
            detectionTimestamp: detection.timestamp,
            beaconType: 'DEDICATED_BEACON',
          ),
        )
        .toList();
  }

  /// Create a ProximityVerificationRequest for API submission
  ProximityVerificationRequest createVerificationRequest({
    required String sessionToken,
    required String studentIndex,
    String? expectedRoomId,
    int? attendanceId,
  }) {
    return ProximityVerificationRequest(
      studentIndex: studentIndex,
      sessionToken: sessionToken,
      attendanceId: attendanceId,
      expectedRoomId: expectedRoomId ?? (_lastValidDetection?.roomId ?? ''),
      verificationDurationSeconds:
          _detectionHistory.isNotEmpty
              ? _detectionHistory.last.timestamp.difference(_detectionHistory.first.timestamp).inSeconds
              : 0,
      proximityDetections: getProximityDetectionsForApi(sessionToken: sessionToken, studentIndex: studentIndex),
    );
  }

  /// Get current proximity status description
  String getProximityDescription(ProximityLevel level) {
    switch (level) {
      case ProximityLevel.near:
        return "Very Close (< 2m)";
      case ProximityLevel.medium:
        return "In Classroom (2-15m)";
      case ProximityLevel.far:
        return "Large Hall Range (15-30m)";
      case ProximityLevel.outOfRange:
        return "Out of Range (> 30m)";
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
