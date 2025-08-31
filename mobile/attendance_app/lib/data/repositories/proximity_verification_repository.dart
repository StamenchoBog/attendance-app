import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class ProximityVerificationRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'ProximityVerificationRepository';

  ProximityVerificationRepository(this._apiClient);

  Future<Map<String, dynamic>?> verifyProximity({
    required String studentIndex,
    required String sessionToken,
    required int attendanceId,
    required String expectedRoomId,
    required int verificationDurationSeconds,
    required List<Map<String, dynamic>> proximityDetections,
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleRepositoryError<Map<String, dynamic>>(
      () async {
        final requestBody = {
          'studentIndex': studentIndex,
          'sessionToken': sessionToken,
          'attendanceId': attendanceId,
          'expectedRoomId': expectedRoomId,
          'verificationDurationSeconds': verificationDurationSeconds,
          'proximityDetections': proximityDetections,
        };

        final response = await _apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.attendanceVerifyProximity,
          data: requestBody,
        );

        // Updated to handle the new API response structure
        final verificationData = response.data?['data'] as Map<String, dynamic>?;
        return verificationData ?? {};
      },
      _repositoryName,
      'verifyProximity',
      showDialog: context != null,
      context: context,
    );
  }

  Future<bool> logProximityDetection({
    required String studentIndex,
    required String sessionToken,
    required String beaconDeviceId,
    required String detectedRoomId,
    required int rssi,
    required String proximityLevel,
    required double estimatedDistance,
    required DateTime detectionTimestamp,
    required String beaconType,
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleAsyncVoidError(
      () async {
        final requestBody = {
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

        await _apiClient.post<void>(ApiEndpoints.attendanceLogProximityDetection, data: requestBody);
      },
      '$_repositoryName.logProximityDetection',
      showDialog: context != null,
      context: context,
    );
  }
}
