import 'dart:typed_data';
import 'package:attendance_app/core/utils/semester_util.dart';
import 'package:attendance_app/data/models/student_attendance.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class AttendanceRepository {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  AttendanceRepository(this._apiClient);

  Future<int> registerAttendance({
    required String token,
    required String studentIndex,
    required String deviceId,
  }) async {
    final requestBody = {'token': token, 'studentIndex': studentIndex, 'deviceId': deviceId};

    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiEndpoints.attendance}/register',
        data: requestBody,
      );
      return response.data?['data'] as int;
    } on ApiException catch (e) {
      _logger.e('Failed to register attendance: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error during attendance registration: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> confirmAttendance({required int attendanceId, required String proximity}) async {
    final requestBody = {'attendanceId': attendanceId, 'proximity': proximity};

    try {
      await _apiClient.post<void>('${ApiEndpoints.attendance}/confirm', data: requestBody);
    } on ApiException catch (e) {
      _logger.e('Failed to confirm attendance: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error during attendance confirmation: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<List<StudentAttendance>> getStudentAttendanceForSession(int sessionId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.attendance}/lecture/$sessionId');
      final data = response.data?['data'] as List;
      return data.map((json) => StudentAttendance.fromJson(json)).toList();
    } on ApiException catch (e) {
      _logger.e('Failed to get student attendance: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error getting student attendance: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<Uint8List> generateQrCode(int sessionId) async {
    try {
      final response = await _apiClient.post<List<int>>(
        '${ApiEndpoints.qr}/generateQR',
        data: {'professorClassSessionId': sessionId},
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    } on ApiException catch (e) {
      _logger.e('Failed to generate QR code: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error generating QR code: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<Map<String, dynamic>> createPresentationSession(int sessionId, {String? beaconMode}) async {
    try {
      final data = <String, dynamic>{};
      if (beaconMode != null) {
        data['beaconMode'] = beaconMode;
      }

      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiEndpoints.presentation}/$sessionId',
        data: data
      );
      return response.data?['data'] ?? {};
    } on ApiException catch (e) {
      _logger.e('Failed to create presentation session: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error creating presentation session: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<Map<String, dynamic>> getAttendanceSummary(String studentIndex) async {
    try {
      final semester = getCurrentSemester();
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiEndpoints.students}/$studentIndex/attendance-summary',
        queryParameters: {'semester': semester},
      );
      return response.data?['data'] ?? {};
    } on ApiException catch (e) {
      _logger.e('Failed to get attendance summary: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error getting attendance summary: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}
