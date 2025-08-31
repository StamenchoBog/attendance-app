import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/models/scheduled_class_session.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class ClassSessionRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'ClassSessionRepository';

  ClassSessionRepository(this._apiClient);

  Future<List<Map<String, dynamic>>?> getProfessorClassSessionsByDate({
    required String professorId,
    required DateTime date,
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleRepositoryError<List<Map<String, dynamic>>>(
      () async {
        final requestBody = {'professorId': professorId, 'date': date.toIso8601String().split('T')[0]};

        final response = await _apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.classSessionsByProfessorByDate,
          data: requestBody,
        );

        // Updated to handle the new API response structure
        final List<dynamic> sessionsList = response.data?['data'] ?? [];
        return sessionsList.cast<Map<String, dynamic>>();
      },
      _repositoryName,
      'getProfessorClassSessionsByDate',
      showDialog: context != null,
      context: context,
    );
  }

  Future<List<Map<String, dynamic>>?> getProfessorCurrentWeekSessions(
    String professorId, {
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleRepositoryError<List<Map<String, dynamic>>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(
          '${ApiEndpoints.classSessionsByProfessorCurrentWeek}/$professorId/current-week',
        );

        // Updated to handle the new API response structure
        final List<dynamic> sessionsList = response.data?['data'] ?? [];
        return sessionsList.cast<Map<String, dynamic>>();
      },
      _repositoryName,
      'getProfessorCurrentWeekSessions',
      showDialog: context != null,
      context: context,
    );
  }

  Future<List<Map<String, dynamic>>?> getProfessorCurrentMonthSessions(
    String professorId, {
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleRepositoryError<List<Map<String, dynamic>>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(
          '${ApiEndpoints.classSessionsByProfessorCurrentMonth}/$professorId/current-month',
        );

        // Updated to handle the new API response structure
        final List<dynamic> sessionsList = response.data?['data'] ?? [];
        return sessionsList.cast<Map<String, dynamic>>();
      },
      _repositoryName,
      'getProfessorCurrentMonthSessions',
      showDialog: context != null,
      context: context,
    );
  }

  Future<List<Map<String, dynamic>>?> getClassSessionsByStudentIndexForGivenDateAndTime({
    required String studentIndex,
    required String dateTime,
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleRepositoryError<List<Map<String, dynamic>>>(
      () async {
        final requestBody = {'studentIndex': studentIndex, 'dateTime': dateTime};

        final response = await _apiClient.post<Map<String, dynamic>>(
          ApiEndpoints.classSessionsByStudentByDateOverview,
          data: requestBody,
        );

        // Updated to handle the new API response structure
        final List<dynamic> sessionsList = response.data?['data'] ?? [];
        return sessionsList.cast<Map<String, dynamic>>();
      },
      _repositoryName,
      'getClassSessionsByStudentIndexForGivenDateAndTime',
      showDialog: context != null,
      context: context,
    );
  }
}
