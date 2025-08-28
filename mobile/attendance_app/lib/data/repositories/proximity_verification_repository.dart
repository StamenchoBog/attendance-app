import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/proximity_verification_models.dart';
import '../services/service_starter.dart';

class ProximityVerificationRepository {
  final Dio _dio = locator<Dio>();
  final Logger _logger = Logger();

  /// Log individual proximity detection during verification
  Future<void> logProximityDetection(ProximityDetectionRequest detection) async {
    try {
      _logger.d('Logging proximity detection: ${detection.proximityLevel} at ${detection.estimatedDistance}m');

      final response = await _dio.post('/attendance/log-proximity-detection', data: detection.toJson());

      if (response.statusCode != 200) {
        throw Exception('Failed to log proximity detection: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error logging proximity detection: $e');
      throw Exception('Failed to log proximity detection: $e');
    }
  }

  /// Submit comprehensive proximity verification with all collected readings
  Future<ProximityVerificationResponse> verifyProximity(ProximityVerificationRequest request) async {
    try {
      _logger.i(
        'Submitting proximity verification for student ${request.studentIndex} with ${request.proximityDetections.length} detections',
      );

      final response = await _dio.post('/attendance/verify-proximity', data: request.toJson());

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return ProximityVerificationResponse.fromJson(data);
      } else {
        throw Exception('Proximity verification failed: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error during proximity verification: $e');
      throw Exception('Proximity verification failed: $e');
    }
  }

  /// Get proximity analytics for a room (for professors)
  Future<RoomProximityAnalytics> getRoomAnalytics(String roomId, {int daysBack = 7}) async {
    try {
      _logger.i('Fetching proximity analytics for room $roomId');

      final response = await _dio.get(
        '/attendance/proximity-analytics/$roomId',
        queryParameters: {'daysBack': daysBack},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return RoomProximityAnalytics.fromJson(data);
      } else {
        throw Exception('Failed to fetch room analytics: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching room analytics: $e');
      throw Exception('Failed to fetch room analytics: $e');
    }
  }
}
