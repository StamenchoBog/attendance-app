import 'dart:convert';
import 'package:attendance_app/core/utils/semester_util.dart';
import 'package:attendance_app/data/models/student_attendance.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/foundation.dart';

class AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepository(this._apiClient);

  Future<int> registerAttendance({
    required String token,
    required String studentIndex,
  }) async {
    final requestBody = {
      'token': token,
      'studentIndex': studentIndex,
    };

    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.attendance}/register',
        requestBody,
      );
      return response['data'];
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> confirmAttendance({
    required int attendanceId,
    required String proximity,
  }) async {
    final requestBody = {
      'attendanceId': attendanceId,
      'proximity': proximity,
    };

    try {
      await _apiClient.post(
        '${ApiEndpoints.attendance}/confirm',
        requestBody,
      );
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<List<StudentAttendance>> getStudentAttendanceForSession(int sessionId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.attendance}/lecture/$sessionId');
      return (response['data'] as List)
          .map((json) => StudentAttendance.fromJson(json))
          .toList();
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<Uint8List> generateQrCode(int sessionId) async {
    try {
      final response = await _apiClient.postAndGetBytes(
        '${ApiEndpoints.qr}/generateQR',
        {'professorClassSessionId': sessionId},
      );
      return response;
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<Map<String, dynamic>> createPresentationSession(int sessionId) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.presentation}/$sessionId',
        {},
      );
      return response['data'];
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<Map<String, dynamic>> getAttendanceSummary(String studentIndex) async {
    try {
      final semester = getCurrentSemester();
      final response = await _apiClient.get('${ApiEndpoints.students}/$studentIndex/attendance-summary?semester=$semester');
      return response['data'];
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}
