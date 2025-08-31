import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/models/professor.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class ProfessorRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'ProfessorRepository';

  ProfessorRepository(this._apiClient);

  Future<List<Professor>?> getAllProfessors({BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<List<Professor>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.professors);

        // Updated to handle the new API response structure
        final List<dynamic> professorsList = response.data?['data'] ?? [];
        return professorsList.map((json) => Professor.fromJson(json as Map<String, dynamic>)).toList();
      },
      _repositoryName,
      'getAllProfessors',
      showDialog: context != null,
      context: context,
    );
  }

  Future<Professor?> getProfessorById(String professorId, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<Professor>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.professors}/$professorId');

        // Updated to handle the new API response structure
        final professorData = response.data?['data'] as Map<String, dynamic>?;
        if (professorData == null) {
          throw Exception('No professor data found');
        }

        return Professor.fromJson(professorData);
      },
      _repositoryName,
      'getProfessorById',
      showDialog: context != null,
      context: context,
    );
  }
}
