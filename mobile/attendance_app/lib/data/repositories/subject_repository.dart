import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_app/data/models/subject.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';

class SubjectRepository {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  SubjectRepository(this._apiClient);

  Future<List<Subject>> getSubjectsByProfessorId(String professorId) async {
    final cacheKey = 'cached_subjects_$professorId';
    final timestampKey = 'subjects_cache_timestamp_$professorId';

    try {
      // Fetch from API with proper Dio response handling
      final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.subjects}/by-professor/$professorId');
      final data = response.data?['data'] as List;
      final subjects = data.map((json) => Subject.fromJson(json)).toList();

      // Cache the new data
      await _cacheSubjects(subjects, cacheKey, timestampKey);

      return subjects;
    } on ApiException catch (e) {
      _logger.w('API failed, trying cache: ${e.message}');
      return await _getCachedSubjects(cacheKey, timestampKey);
    } catch (e) {
      _logger.e('Unexpected error getting subjects: $e');
      // Try cache as fallback
      try {
        return await _getCachedSubjects(cacheKey, timestampKey);
      } catch (cacheError) {
        _logger.e('Cache also failed: $cacheError');
        throw 'Unable to load subjects. Please check your connection.';
      }
    }
  }

  Future<List<Subject>> getAllSubjects() async {
    const cacheKey = 'cached_all_subjects';
    const timestampKey = 'all_subjects_cache_timestamp';

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.subjects);
      final data = response.data?['data'] as List;
      final subjects = data.map((json) => Subject.fromJson(json)).toList();

      await _cacheSubjects(subjects, cacheKey, timestampKey);
      return subjects;
    } on ApiException catch (e) {
      _logger.w('API failed, trying cache: ${e.message}');
      return await _getCachedSubjects(cacheKey, timestampKey);
    } catch (e) {
      _logger.e('Unexpected error getting all subjects: $e');
      try {
        return await _getCachedSubjects(cacheKey, timestampKey);
      } catch (cacheError) {
        _logger.e('Cache also failed: $cacheError');
        throw 'Unable to load subjects. Please check your connection.';
      }
    }
  }

  // Private helper methods
  Future<void> _cacheSubjects(List<Subject> subjects, String cacheKey, String timestampKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectsJson = subjects.map((subject) => subject.toJson()).toList();
      await prefs.setString(cacheKey, jsonEncode(subjectsJson));
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _logger.w('Failed to cache subjects: $e');
      // Don't throw, caching is optional
    }
  }

  Future<List<Subject>> _getCachedSubjects(String cacheKey, String timestampKey) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(cacheKey);
    final cacheTimestamp = prefs.getInt(timestampKey) ?? 0;

    // Check if cache is too old (24 hours)
    final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTimestamp;
    if (cacheAge > 24 * 60 * 60 * 1000) {
      throw 'Cached data is too old';
    }

    if (cachedData != null) {
      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.map((json) => Subject.fromJson(json)).toList();
    }

    throw 'No cached subjects available';
  }
}
