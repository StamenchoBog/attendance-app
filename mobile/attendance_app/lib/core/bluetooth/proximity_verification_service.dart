import 'dart:async';
import '../../data/models/beacon_models.dart';
import '../../data/models/proximity_verification_models.dart';
import 'package:logger/logger.dart';
import 'beacon_scanner.dart';

/// Handles proximity verification workflow and business logic
class ProximityVerificationService {
  final BeaconScanner _scanner = BeaconScanner();
  static final Logger _logger = Logger();

  // Configuration
  static const Duration defaultVerificationDuration = Duration(minutes: 2);
  static const Duration detectionInterval = Duration(seconds: 3);
  static const int minimumDetectionsRequired = 3;
  static const double consistencyThreshold = 0.7;

  final List<BeaconDetection> _detectionHistory = [];
  final StreamController<BeaconDetection> _detectionController = StreamController.broadcast();
  final StreamController<ProximityVerificationProgress> _progressController = StreamController.broadcast();

  // Public streams
  Stream<BeaconDetection> get detections => _detectionController.stream;
  Stream<ProximityVerificationProgress> get progress => _progressController.stream;

  /// Start comprehensive proximity verification workflow
  Future<ProximityVerificationResponse> startVerification({
    required String sessionToken,
    required String studentIndex,
    String? expectedRoomId,
    Duration? duration,
  }) async {
    _logger.d("Starting proximity verification for student: $studentIndex");

    _detectionHistory.clear();
    final verificationDuration = duration ?? defaultVerificationDuration;
    final startTime = DateTime.now();

    try {
      _updateProgress("Searching for classroom beacon...", 0.1);

      // Initial beacon detection
      final initialDetection = await _scanner.scanForBeacon(timeout: const Duration(seconds: 30));

      if (initialDetection == null) {
        return _createFailureResponse(
          startTime,
          'FAILED',
          "No beacon detected. Please ensure you are in the classroom."
        );
      }

      _detectionHistory.add(initialDetection);
      _detectionController.add(initialDetection);

      // Room validation
      if (expectedRoomId != null && !_isRoomMatch(initialDetection.roomId, expectedRoomId)) {
        return _createFailureResponse(
          startTime,
          'WRONG_ROOM',
          "Wrong classroom. Expected: $expectedRoomId, Found: ${initialDetection.roomId}",
          detectedRoomId: initialDetection.roomId,
        );
      }

      // Continuous verification
      _updateProgress("Verifying presence in ${initialDetection.roomId}...", 0.3);

      final endTime = startTime.add(verificationDuration);
      var lastDetectionTime = DateTime.now();

      while (DateTime.now().isBefore(endTime)) {
        await Future.delayed(detectionInterval);

        final progress = DateTime.now().difference(startTime).inMilliseconds / verificationDuration.inMilliseconds;
        _updateProgress("Collecting verification data...", 0.3 + (progress * 0.6));

        try {
          final detection = await _scanner.scanForBeacon(timeout: const Duration(seconds: 5));

          if (detection != null) {
            _detectionHistory.add(detection);
            _detectionController.add(detection);
            lastDetectionTime = DateTime.now();
          } else {
            // Check if we've lost connection too long
            final timeSinceLastDetection = DateTime.now().difference(lastDetectionTime);
            if (timeSinceLastDetection > const Duration(seconds: 30)) {
              return _createFailureResponse(
                startTime,
                'OUT_OF_RANGE',
                "Lost connection to beacon. You may have left the room.",
                detectedRoomId: initialDetection.roomId,
              );
            }
          }
        } catch (e) {
          _logger.e("Detection error during verification: $e");
          // Continue verification even if individual scans fail
        }
      }

      // Evaluate results
      _updateProgress("Analyzing verification data...", 0.95);
      return _evaluateVerification(startTime, expectedRoomId);

    } catch (e) {
      _logger.e("Verification error: $e");
      return _createFailureResponse(startTime, 'FAILED', "Verification failed: $e");
    }
  }

  /// Convert detections to API format
  List<ProximityDetectionRequest> getApiDetections({
    required String sessionToken,
    required String studentIndex,
  }) {
    return _detectionHistory.map((detection) => ProximityDetectionRequest(
      studentIndex: studentIndex,
      sessionToken: sessionToken,
      beaconDeviceId: detection.deviceId,
      detectedRoomId: detection.roomId,
      rssi: detection.rssi,
      proximityLevel: detection.proximity.name.toUpperCase(),
      estimatedDistance: detection.estimatedDistance,
      detectionTimestamp: detection.timestamp,
      beaconType: 'CLASSROOM_BEACON',
    )).toList();
  }

  /// Quick proximity check (for legacy compatibility)
  Future<String?> getQuickProximity({Duration? timeout}) async {
    try {
      final detection = await _scanner.scanForBeacon(timeout: timeout);
      if (detection != null) {
        final proximityLevel = _getSimpleProximityString(detection.proximity);
        return "${detection.roomId}:$proximityLevel";
      }
      return null;
    } catch (e) {
      _logger.e("Quick proximity check failed: $e");
      return null;
    }
  }

  /// Evaluate verification results
  ProximityVerificationResponse _evaluateVerification(DateTime startTime, String? expectedRoomId) {
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime).inSeconds;

    if (_detectionHistory.isEmpty) {
      return _createFailureResponse(startTime, 'FAILED', "No detections recorded");
    }

    // Analyze consistency
    final roomCounts = <String, int>{};
    var totalDistance = 0.0;
    var validDetections = 0;

    for (final detection in _detectionHistory) {
      roomCounts[detection.roomId] = (roomCounts[detection.roomId] ?? 0) + 1;
      totalDistance += detection.estimatedDistance;

      if (detection.proximity != ProximityLevel.outOfRange) {
        validDetections++;
      }
    }

    final mostDetectedRoom = roomCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final roomConsistency = roomCounts[mostDetectedRoom]! / _detectionHistory.length;
    final averageDistance = totalDistance / _detectionHistory.length;

    // Determine success
    String status;
    String? failureReason;
    bool success = false;

    if (_detectionHistory.length < minimumDetectionsRequired) {
      status = 'INSUFFICIENT';
      failureReason = "Insufficient detections (${_detectionHistory.length}/$minimumDetectionsRequired)";
    } else if (roomConsistency < consistencyThreshold) {
      status = 'INCONSISTENT';
      failureReason = "Inconsistent room detections (${(roomConsistency * 100).toStringAsFixed(1)}% consistency)";
    } else if (averageDistance > 50) {
      status = 'TOO_FAR';
      failureReason = "Average distance too far (${averageDistance.toStringAsFixed(1)}m)";
    } else if (validDetections < (_detectionHistory.length * 0.8)) {
      status = 'LOW_QUALITY';
      failureReason = "Too many out-of-range detections";
    } else {
      success = true;
      status = 'SUCCESS';
    }

    _updateProgress(success ? "Verification successful!" : failureReason ?? "Verification failed", 1.0);

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
      actualDurationSeconds: duration,
      failureReason: failureReason,
    );
  }

  /// Helper methods
  ProximityVerificationResponse _createFailureResponse(
    DateTime startTime,
    String status,
    String reason, {
    String? detectedRoomId,
  }) {
    return ProximityVerificationResponse(
      verificationSuccess: false,
      verificationStatus: status,
      detectedRoomId: detectedRoomId ?? '',
      expectedRoomId: '',
      averageDistance: 0.0,
      totalDetections: _detectionHistory.length,
      validDetections: 0,
      verificationStartTime: startTime,
      verificationEndTime: DateTime.now(),
      actualDurationSeconds: DateTime.now().difference(startTime).inSeconds,
      failureReason: reason,
    );
  }

  void _updateProgress(String message, double progress) {
    _progressController.add(ProximityVerificationProgress(
      message: message,
      progress: progress.clamp(0.0, 1.0),
      detectionCount: _detectionHistory.length,
    ));
  }

  bool _isRoomMatch(String detected, String expected) {
    if (detected == expected) return true;

    final normalizedDetected = detected.replaceAll(' ', '').toLowerCase();
    final normalizedExpected = expected.replaceAll(' ', '').toLowerCase();

    return normalizedDetected == normalizedExpected ||
           normalizedDetected.contains(normalizedExpected) ||
           normalizedExpected.contains(normalizedDetected);
  }

  String _getSimpleProximityString(ProximityLevel level) {
    switch (level) {
      case ProximityLevel.near: return "NEAR";
      case ProximityLevel.medium: return "MEDIUM";
      case ProximityLevel.far: return "FAR";
      case ProximityLevel.outOfRange: return "FAR";
    }
  }

  void dispose() {
    _detectionController.close();
    _progressController.close();
  }
}

/// Progress update during verification
class ProximityVerificationProgress {
  final String message;
  final double progress; // 0.0 to 1.0
  final int detectionCount;

  ProximityVerificationProgress({
    required this.message,
    required this.progress,
    required this.detectionCount,
  });
}
