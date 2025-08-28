import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';

class ClassSessionRepository {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  ClassSessionRepository(this._apiClient);

  // Get class sessions for a student on a specific date
  Future<List<dynamic>> getClassSessionsByStudentAndDateTime(String studentIndex, DateTime dateTime) async {
    try {
      // Create request body
      final body = {'studentIndex': studentIndex, 'dateTime': DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(dateTime)};

      // Make API request using proper Dio response handling
      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiEndpoints.classSessions}/by-student/by-date/overview',
        data: body,
      );

      return response.data?['data'] ?? [];
    } on ApiException catch (e) {
      _logger.e('Error fetching student class sessions: ${e.statusCode} - ${e.message}');
      throw 'Failed to fetch class sessions. Please try again.';
    } catch (e) {
      _logger.e('Unexpected error fetching student class sessions: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<List<dynamic>> getProfessorClassSessions(String professorId, DateTime date) async {
    try {
      final body = {'professorId': professorId, 'date': DateFormat('yyyy-MM-dd').format(date)};

      final response = await _apiClient.post<Map<String, dynamic>>(
        '${ApiEndpoints.classSessions}/by-professor/by-date',
        data: body,
      );

      return response.data?['data'] ?? [];
    } on ApiException catch (e) {
      _logger.e('Error fetching professor class sessions: ${e.statusCode} - ${e.message}');
      throw 'Failed to fetch professor class sessions. Please try again.';
    } catch (e) {
      _logger.e('Unexpected error fetching professor class sessions: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<Map<String, dynamic>?> getClassSessionDetails(int sessionId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.classSessions}/$sessionId');

      return response.data?['data'];
    } on ApiException catch (e) {
      _logger.e('Error fetching class session details: ${e.statusCode} - ${e.message}');
      throw 'Failed to fetch class session details. Please try again.';
    } catch (e) {
      _logger.e('Unexpected error fetching class session details: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<List<dynamic>> getUpcomingClassSessions(String userId, String userType) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '${ApiEndpoints.classSessions}/upcoming',
        queryParameters: {'userId': userId, 'userType': userType},
      );

      return response.data?['data'] ?? [];
    } on ApiException catch (e) {
      _logger.e('Error fetching upcoming class sessions: ${e.statusCode} - ${e.message}');
      throw 'Failed to fetch upcoming class sessions. Please try again.';
    } catch (e) {
      _logger.e('Unexpected error fetching upcoming class sessions: $e');
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}
