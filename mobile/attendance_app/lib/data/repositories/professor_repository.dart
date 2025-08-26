import 'dart:convert';
import 'package:attendance_app/data/models/professor.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfessorRepository {
  final ApiClient _apiClient;
  static const String _cacheKey = 'cached_professors';

  ProfessorRepository(this._apiClient);

  Future<List<Professor>> getProfessors() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);

    try {
      // Fetch from API
      final response = await _apiClient.get(ApiEndpoints.professors);
      final professors = (response['data'] as List)
          .map((json) => Professor.fromJson(json))
          .toList();

      // Cache the new data
      await prefs.setString(_cacheKey, jsonEncode(professors.map((p) => p.toJson()).toList()));
      
      return professors;
    } catch (e) {
      // If API fails, try to use cached data
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((json) => Professor.fromJson(json)).toList();
      }
      
      // If no cache and API fails, rethrow
      if (e is ApiException) {
        throw e.message;
      }
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<Professor> getProfessorById(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.professors}/$id');
      return Professor.fromJson(response['data']);
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}