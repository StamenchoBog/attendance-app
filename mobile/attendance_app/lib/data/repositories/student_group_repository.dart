import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class StudentGroupRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'StudentGroupRepository';

  StudentGroupRepository(this._apiClient);

  Future<List<Map<String, dynamic>>?> getAllStudentGroups({BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<List<Map<String, dynamic>>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.studentsGroups);

        final List<dynamic> groupsList = response.data?['data'] ?? [];
        return groupsList.cast<Map<String, dynamic>>();
      },
      _repositoryName,
      'getAllStudentGroups',
      showDialog: context != null,
      context: context,
    );
  }

  Future<Map<String, dynamic>?> getStudentGroupById(int id, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<Map<String, dynamic>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.studentsGroups}/$id');

        final groupData = response.data?['data'] as Map<String, dynamic>?;
        return groupData ?? {};
      },
      _repositoryName,
      'getStudentGroupById',
      showDialog: context != null,
      context: context,
    );
  }

  Future<Map<String, dynamic>?> getStudentGroupByName(String name, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<Map<String, dynamic>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.studentsGroupsByName}/$name');

        // Updated to handle the new API response structure
        final groupData = response.data?['data'] as Map<String, dynamic>?;
        return groupData ?? {};
      },
      _repositoryName,
      'getStudentGroupByName',
      showDialog: context != null,
      context: context,
    );
  }
}
