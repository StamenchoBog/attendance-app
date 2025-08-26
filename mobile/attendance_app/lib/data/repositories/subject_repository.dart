import 'dart:convert';
import 'package:attendance_app/data/models/subject.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubjectRepository {
  final ApiClient _apiClient;

  SubjectRepository(this._apiClient);

  Future<List<Subject>> getSubjectsByProfessorId(String professorId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_subjects_$professorId';
    final cachedData = prefs.getString(cacheKey);

    try {
      // Fetch from API
      final response = await _apiClient.get('${ApiEndpoints.subjects}/by-professor/$professorId');
      final subjects = (response['data'] as List)
          .map((json) => Subject.fromJson(json))
          .toList();
      
      // Cache the new data
      await prefs.setString(cacheKey, jsonEncode(subjects.map((s) => s.toJson()).toList()));

      return subjects;
    } catch (e) {
      // If API fails, try to use cached data
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((json) => Subject.fromJson(json)).toList();
      }

      // If no cache and API fails, rethrow
      if (e is ApiException) {
        throw e.message;
      }
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}