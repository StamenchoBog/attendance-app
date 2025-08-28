import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_app/data/models/professor.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';

class ProfessorRepository {
  final ApiClient _apiClient;
  final Logger _logger = Logger();
  static const String _cacheKey = 'cached_professors';
  static const String _cacheTimestampKey = 'professors_cache_timestamp';

  ProfessorRepository(this._apiClient);

  Future<List<Professor>> getProfessors() async {
    try {
      // Fetch from API with proper Dio response handling
      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.professors);
      final data = response.data?['data'] as List;
      final professors = data.map((json) => Professor.fromJson(json)).toList();

      // Cache the new data
      await _cacheProfessors(professors);

      return professors;
    } on ApiException catch (e) {
      _logger.w('API failed, trying cache: ${e.message}');
      return await _getCachedProfessors();
    } catch (e) {
      _logger.e('Unexpected error getting professors: $e');
      // Try cache as fallback
      try {
        return await _getCachedProfessors();
      } catch (cacheError) {
        _logger.e('Cache also failed: $cacheError');
        throw 'Unable to load professors. Please check your connection.';
      }
    }
  }

  Future<Professor?> getProfessorById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.professors}/$id');
      final data = response.data?['data'];
      return data != null ? Professor.fromJson(data) : null;
    } on ApiException catch (e) {
      _logger.e('Failed to get professor by ID: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error getting professor by ID: $e');
      throw 'Unable to load professor details.';
    }
  }

  Future<List<dynamic>> getProfessorSubjects(String professorId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.professors}/$professorId/subjects');
      return response.data?['data'] ?? [];
    } on ApiException catch (e) {
      _logger.e('Failed to get professor subjects: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error getting professor subjects: $e');
      throw 'Unable to load professor subjects.';
    }
  }

  // Private helper methods
  Future<void> _cacheProfessors(List<Professor> professors) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final professorsJson = professors.map((professor) => professor.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(professorsJson));
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _logger.w('Failed to cache professors: $e');
      // Don't throw, caching is optional
    }
  }

  Future<List<Professor>> _getCachedProfessors() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    final cacheTimestamp = prefs.getInt(_cacheTimestampKey) ?? 0;

    // Check if cache is too old (24 hours)
    final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTimestamp;
    if (cacheAge > 24 * 60 * 60 * 1000) {
      throw 'Cached data is too old';
    }

    if (cachedData != null) {
      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.map((json) => Professor.fromJson(json)).toList();
    }

    throw 'No cached professors available';
  }
}
