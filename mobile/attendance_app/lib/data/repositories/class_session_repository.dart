import 'package:intl/intl.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:logger/logger.dart';

class ClassSessionRepository {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  ClassSessionRepository(this._apiClient);

  // Get class sessions for a student on a specific date
  Future<List<dynamic>> getClassSessionsByStudentAndDateTime(
    String studentIndex,
    DateTime dateTime,
  ) async {
    try {
      // Create request body
      final body = {
        'studentIndex': studentIndex,
        'dateTime': DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(dateTime),
      };

      // Make API request
      final response = await _apiClient.post(
        '${ApiEndpoints.classSessions}/by-student/by-date/overview',
        body,
      );

      return response['data'];
    } on ApiException catch (e) {
      _logger.e('Error fetching classes: ${e.statusCode} - ${e.message}');
      throw 'Failed to fetch class sessions. Please try again.';
    } catch (e) {
      _logger.e('Exception fetching classes: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<List<dynamic>> getProfessorClassSessions(
      String professorId, DateTime date) async {
    try {
      final body = {
        'professorId': professorId,
        'date': DateFormat('yyyy-MM-dd').format(date),
      };
      final response = await _apiClient.post(
        '${ApiEndpoints.classSessions}/by-professor/by-date',
        body,
      );
      if (response == null || response['data'] == null) {
        return [];
      }
      return response['data'];
    } on ApiException catch (e) {
      _logger.e('Error fetching professor classes: ${e.statusCode} - ${e.message}');
      throw 'Failed to fetch professor class sessions. Please try again.';
    } catch (e) {
      _logger.e('Exception fetching professor classes: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}
