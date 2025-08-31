import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/models/subject.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class SubjectRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'SubjectRepository';

  SubjectRepository(this._apiClient);

  /// GET /subjects - Gets all subjects
  Future<List<Subject>?> getAllSubjects({BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<List<Subject>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.subjects);

        // Updated to handle the new API response structure
        final List<dynamic> subjectsList = response.data?['data'] ?? [];
        return subjectsList.map((json) => Subject.fromJson(json as Map<String, dynamic>)).toList();
      },
      _repositoryName,
      'getAllSubjects',
      showDialog: context != null,
      context: context,
    );
  }

  /// GET /subjects/{id} - Gets subject by ID
  Future<Subject?> getSubjectById(String subjectId, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<Subject>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.subjects}/$subjectId');

        // Updated to handle the new API response structure
        final subjectData = response.data?['data'] as Map<String, dynamic>?;
        if (subjectData == null) {
          throw Exception('No subject data found');
        }

        return Subject.fromJson(subjectData);
      },
      _repositoryName,
      'getSubjectById',
      showDialog: context != null,
      context: context,
    );
  }

  /// GET /subjects/by-professor/{professorId} - Gets subjects by professor ID
  Future<List<Subject>?> getSubjectsByProfessorId(String professorId, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<List<Subject>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.subjectsByProfessor}/$professorId');

        // Updated to handle the new API response structure
        final List<dynamic> subjectsList = response.data?['data'] ?? [];
        return subjectsList.map((json) => Subject.fromJson(json as Map<String, dynamic>)).toList();
      },
      _repositoryName,
      'getSubjectsByProfessorId',
      showDialog: context != null,
      context: context,
    );
  }
}
