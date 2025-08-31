import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class SemesterRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'SemesterRepository';

  SemesterRepository(this._apiClient);

  Future<List<Map<String, dynamic>>?> getAllSemesters({BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<List<Map<String, dynamic>>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.semesters);

        final List<dynamic> semestersList = response.data?['data'] ?? [];
        return semestersList.cast<Map<String, dynamic>>();
      },
      _repositoryName,
      'getAllSemesters',
      showDialog: context != null,
      context: context,
    );
  }

  Future<Map<String, dynamic>?> getSemesterByCode(String code, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<Map<String, dynamic>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.semesters}/$code');

        final semesterData = response.data?['data'] as Map<String, dynamic>?;
        return semesterData ?? {};
      },
      _repositoryName,
      'getSemesterByCode',
      showDialog: context != null,
      context: context,
    );
  }
}
