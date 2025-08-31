import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class StudentRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'StudentRepository';

  StudentRepository(this._apiClient);

  Future<Student?> getStudentByIndex(String studentIndex, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<Student>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.students}/$studentIndex');

        // Updated to handle the new API response structure
        final studentData = response.data?['data'] as Map<String, dynamic>?;
        if (studentData == null) {
          throw Exception('No student data found');
        }

        return Student.fromJson(studentData);
      },
      _repositoryName,
      'getStudentByIndex',
      showDialog: context != null,
      context: context,
    );
  }

  Future<List<Student>?> getStudentsByProfessor(String professorId, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<List<Student>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.studentsByProfessor}/$professorId');

        // Updated to handle the new API response structure
        final List<dynamic> studentsList = response.data?['data'] ?? [];
        return studentsList.map((json) => Student.fromJson(json as Map<String, dynamic>)).toList();
      },
      _repositoryName,
      'getStudentsByProfessor',
      showDialog: context != null,
      context: context,
    );
  }

  Future<bool?> isStudentValid(String studentIndex, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<bool>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.studentsIsValid}/$studentIndex');

        // Updated to handle the new API response structure
        final isValid = response.data?['data'] as bool?;
        return isValid ?? false;
      },
      _repositoryName,
      'isStudentValid',
      showDialog: context != null,
      context: context,
    );
  }

  Future<Map<String, dynamic>?> getRegisteredDevice(String studentIndex, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<Map<String, dynamic>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(
          '${ApiEndpoints.students}/$studentIndex/registered-device',
        );

        // Updated to handle the new API response structure
        final deviceData = response.data?['data'] as Map<String, dynamic>?;
        return deviceData ?? {};
      },
      _repositoryName,
      'getRegisteredDevice',
      showDialog: context != null,
      context: context,
    );
  }

  Future<Map<String, dynamic>?> getAttendanceSummary(
    String studentIndex,
    String semester, {
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleRepositoryError<Map<String, dynamic>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(
          '${ApiEndpoints.students}/$studentIndex/attendance-summary',
          queryParameters: {'semester': semester},
        );

        // Updated to handle the new API response structure
        final summaryData = response.data?['data'] as Map<String, dynamic>?;
        return summaryData ?? {};
      },
      _repositoryName,
      'getAttendanceSummary',
      showDialog: context != null,
      context: context,
    );
  }

  Future<bool> requestDeviceLink({
    required String studentIndex,
    required String deviceId,
    required String deviceName,
    required String deviceOs,
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleAsyncVoidError(
      () async {
        final requestBody = {'deviceId': deviceId, 'deviceName': deviceName, 'deviceOs': deviceOs};

        await _apiClient.post<void>('${ApiEndpoints.students}/$studentIndex/device-link-request', data: requestBody);
      },
      '$_repositoryName.requestDeviceLink',
      showDialog: context != null,
      context: context,
    );
  }

  /// POST /students/{studentIndex}/register-first-device - Registers first device for student
  Future<bool> registerFirstDevice({
    required String studentIndex,
    required String deviceId,
    required String deviceName,
    required String deviceOs,
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleAsyncVoidError(
      () async {
        final requestBody = {'deviceId': deviceId, 'deviceName': deviceName, 'deviceOs': deviceOs};

        await _apiClient.post<void>('${ApiEndpoints.students}/$studentIndex/register-first-device', data: requestBody);
      },
      '$_repositoryName.registerFirstDevice',
      showDialog: context != null,
      context: context,
    );
  }
}
