import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/models/student_attendance.dart';
import 'package:attendance_app/data/models/proximity_verification_models.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class AttendanceRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'AttendanceRepository';

  AttendanceRepository(this._apiClient);

  Future<int?> registerAttendance({
    required String token,
    required String studentIndex,
    required String deviceId,
    List<ProximityDetectionRequest>? proximityDetections,
    String? expectedRoomId,
    int? verificationDurationSeconds,
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleRepositoryError<int>(
      () async {
        final requestBody = <String, dynamic>{'token': token, 'studentIndex': studentIndex, 'deviceId': deviceId};
        if (proximityDetections != null && proximityDetections.isNotEmpty) {
          requestBody['proximityDetections'] = proximityDetections.map((detection) => detection.toJson()).toList();

          if (expectedRoomId != null) {
            requestBody['expectedRoomId'] = expectedRoomId;
          }

          if (verificationDurationSeconds != null) {
            requestBody['verificationDurationSeconds'] = verificationDurationSeconds;
          }
        }

        try {
          final response = await _apiClient.post<Map<String, dynamic>>(
            ApiEndpoints.attendanceRegister,
            data: requestBody,
          );

          final attendanceId = response.data?['data'] as int?;
          if (attendanceId == null) {
            throw Exception('No attendance ID returned');
          }
          return attendanceId;
        } on ApiException catch (e) {
          if (e.message.contains('Attendance token has expired')) {
            // Handle token expiration explicitly
            if (context != null) {
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: Text('Invalid or Expired QR Code'),
                      content: Text(
                        'The QR code is either invalid or has expired. Please ask the professor to generate a new one or contact them directly.',
                      ),
                      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('OK'))],
                    ),
              );
            }
            throw Exception('Attendance token expired. User needs to contact the professor.');
          }
          rethrow;
        }
      },
      _repositoryName,
      'registerAttendance',
      showDialog: context != null,
      context: context,
    );
  }

  Future<bool> confirmAttendance({required int attendanceId, required String proximity, BuildContext? context}) async {
    return await ErrorHandler.handleAsyncVoidError(
      () async {
        final requestBody = {'attendanceId': attendanceId, 'proximity': proximity};

        await _apiClient.post<void>(ApiEndpoints.attendanceConfirm, data: requestBody);
      },
      '$_repositoryName.confirmAttendance',
      showDialog: context != null,
      context: context,
    );
  }

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

  Future<List<StudentAttendance>?> getStudentAttendancesByLectureId(int lectureId, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<List<StudentAttendance>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.attendanceLecture}/$lectureId');
        final List<dynamic> attendanceList = response.data?['data'] ?? [];
        return attendanceList.map((json) => StudentAttendance.fromJson(json as Map<String, dynamic>)).toList();
      },
      _repositoryName,
      'getStudentAttendancesByLectureId',
      showDialog: context != null,
      context: context,
    );
  }

  Future<StudentAttendance?> getStudentAttendanceById(int studentAttendanceId, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<StudentAttendance>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.attendance}/$studentAttendanceId');
        final attendanceData = response.data?['data'] as Map<String, dynamic>?;
        if (attendanceData == null) {
          throw Exception('No attendance data found');
        }

        return StudentAttendance.fromJson(attendanceData);
      },
      _repositoryName,
      'getStudentAttendanceById',
      showDialog: context != null,
      context: context,
    );
  }

  Future<List<StudentAttendance>?> getStudentAttendanceForStudentIndex(
    String studentIndex, {
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleRepositoryError<List<StudentAttendance>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(
          '${ApiEndpoints.attendanceByStudent}/$studentIndex/previous-30-days',
        );
        final List<dynamic> attendanceList = response.data?['data'] ?? [];
        return attendanceList.map((json) => StudentAttendance.fromJson(json as Map<String, dynamic>)).toList();
      },
      _repositoryName,
      'getStudentAttendanceForStudentIndex',
      showDialog: context != null,
      context: context,
    );
  }

  Future<Map<String, dynamic>?> getRoomProximityAnalytics(String roomId, {int? daysBack, BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<Map<String, dynamic>>(
      () async {
        final queryParams = <String, dynamic>{};
        if (daysBack != null) {
          queryParams['daysBack'] = daysBack;
        }

        final response = await _apiClient.get<Map<String, dynamic>>(
          '${ApiEndpoints.attendanceProximityAnalytics}/$roomId',
          queryParameters: queryParams,
        );
        final analyticsData = response.data?['data'] as Map<String, dynamic>?;
        return analyticsData ?? {};
      },
      _repositoryName,
      'getRoomProximityAnalytics',
      showDialog: context != null,
      context: context,
    );
  }

  Future<List<StudentAttendance>?> getStudentAttendanceForSession(int sessionId, {BuildContext? context}) async {
    return await getStudentAttendancesByLectureId(sessionId, context: context);
  }
}
