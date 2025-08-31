import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class CourseRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'CourseRepository';

  CourseRepository(this._apiClient);

  Future<List<Map<String, dynamic>>?> getAllCourses({BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<List<Map<String, dynamic>>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.courses);

        final List<dynamic> coursesList = response.data?['data'] ?? [];
        return coursesList.cast<Map<String, dynamic>>();
      },
      _repositoryName,
      'getAllCourses',
      showDialog: context != null,
      context: context,
    );
  }

  Future<Map<String, dynamic>?> getCourseById(int courseId, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<Map<String, dynamic>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.courses}/$courseId');

        final courseData = response.data?['data'] as Map<String, dynamic>?;
        return courseData ?? {};
      },
      _repositoryName,
      'getCourseById',
      showDialog: context != null,
      context: context,
    );
  }
}
