import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../models/student.dart';

class StudentRepository {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  StudentRepository(this._apiClient);

  Future<List<Student>> getStudents() async {
    try {
      // Try to get from API first
      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.students);
      final data = response.data?['data'] as List;
      final students = data.map((json) => Student.fromJson(json)).toList();

      // Cache the result for offline access
      await _cacheStudents(students);

      return students;
    } on ApiException catch (e) {
      _logger.w('API failed, trying cache: ${e.message}');
      return await _getCachedStudents();
    } catch (e) {
      _logger.e('Unexpected error getting students: $e');
      // Try cache as fallback
      try {
        return await _getCachedStudents();
      } catch (cacheError) {
        _logger.e('Cache also failed: $cacheError');
        throw 'Unable to load students. Please check your connection.';
      }
    }
  }

  Future<Student?> getStudentById(String studentId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.students}/$studentId');
      final data = response.data?['data'];
      return data != null ? Student.fromJson(data) : null;
    } on ApiException catch (e) {
      _logger.e('Failed to get student by ID: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error getting student by ID: $e');
      throw 'Unable to load student details.';
    }
  }

  Future<Map<String, dynamic>> getStudentSchedule(String studentIndex, String date) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiEndpoints.students}/$studentIndex/schedule',
        queryParameters: {'date': date},
      );
      return response.data?['data'] ?? {};
    } on ApiException catch (e) {
      _logger.e('Failed to get student schedule: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error getting student schedule: $e');
      throw 'Unable to load schedule.';
    }
  }

  Future<void> requestDeviceLink({
    required String studentIndex,
    required String newDeviceId,
    required String deviceName,
  }) async {
    try {
      await _apiClient.post<void>(
        '${ApiEndpoints.students}/$studentIndex/device-link-request',
        data: {'newDeviceId': newDeviceId, 'deviceName': deviceName},
      );
    } on ApiException catch (e) {
      _logger.e('Failed to request device link: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error requesting device link: $e');
      throw 'Unable to request device link.';
    }
  }

  // Private helper methods
  Future<void> _cacheStudents(List<Student> students) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsJson = students.map((student) => student.toJson()).toList();
      await prefs.setString('cached_students', jsonEncode(studentsJson));
      await prefs.setInt('students_cache_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _logger.w('Failed to cache students: $e');
      // Don't throw, caching is optional
    }
  }

  Future<List<Student>> _getCachedStudents() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_students');
    final cacheTimestamp = prefs.getInt('students_cache_timestamp') ?? 0;

    // Check if cache is too old (24 hours)
    final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTimestamp;
    if (cacheAge > 24 * 60 * 60 * 1000) {
      throw 'Cached data is too old';
    }

    if (cachedData != null) {
      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.map((json) => Student.fromJson(json)).toList();
    }

    throw 'No cached students available';
  }
}
