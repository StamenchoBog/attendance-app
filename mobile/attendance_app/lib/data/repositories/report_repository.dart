import 'package:logger/logger.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/data/models/report_enums.dart';

class ReportRepository {
  final ApiClient _apiClient = locator<ApiClient>();
  final Logger _logger = Logger();

  Future<String> submitReport({
    required String reportType,
    required String priority,
    required String title,
    required String description,
    String? stepsToReproduce,
    String? userInfo,
    String? deviceInfo,
  }) async {
    try {
      // Validate input data before sending
      _validateReportData(title, description, reportType, priority);

      final requestBody = <String, dynamic>{
        'reportType': reportType,
        'priority': priority,
        'title': title.trim(),
        'description': description.trim(),
        if (stepsToReproduce?.isNotEmpty == true) 'stepsToReproduce': stepsToReproduce!.trim(),
        if (userInfo?.isNotEmpty == true) 'userInfo': userInfo,
        if (deviceInfo?.isNotEmpty == true) 'deviceInfo': deviceInfo,
      };

      _logger.i('Submitting report with type: $reportType, priority: $priority');

      final response = await _apiClient.post<Map<String, dynamic>>(ApiEndpoints.reportsSubmit, data: requestBody);

      return _extractReportId(response.data);
    } on ApiException catch (e) {
      _logger.e('API error submitting report: ${e.statusCode} - ${e.message}');
      throw ReportSubmissionException('Failed to submit report: ${e.message}', e.statusCode);
    } catch (e) {
      _logger.e('Unexpected error submitting report: $e');
      throw const ReportSubmissionException('An unexpected error occurred while submitting the report');
    }
  }

  Future<List<Map<String, dynamic>>> getUserReports(String userId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.reports}/user/$userId');

      return List<Map<String, dynamic>>.from(response.data?['data'] ?? []);
    } on ApiException catch (e) {
      _logger.e('Failed to get user reports: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error getting user reports: $e');
      throw 'Unable to load reports.';
    }
  }

  void _validateReportData(String title, String description, String reportType, String priority) {
    if (title.trim().isEmpty) {
      throw const ReportValidationException('Report title cannot be empty');
    }
    if (description.trim().isEmpty) {
      throw const ReportValidationException('Report description cannot be empty');
    }
    if (title.trim().length < 5) {
      throw const ReportValidationException('Report title must be at least 5 characters long');
    }
    if (description.trim().length < 10) {
      throw const ReportValidationException('Report description must be at least 10 characters long');
    }

    // Validate enum values
    if (!ReportType.values.any((type) => type.toString().split('.').last == reportType)) {
      throw ReportValidationException('Invalid report type: $reportType');
    }
    if (!ReportPriority.values.any((prio) => prio.toString().split('.').last == priority)) {
      throw ReportValidationException('Invalid priority: $priority');
    }
  }

  String _extractReportId(Map<String, dynamic>? response) {
    if (response == null || response['data'] == null) {
      throw Exception('Invalid response format from server');
    }

    final data = response['data'];
    if (data is Map<String, dynamic> && data.containsKey('reportId')) {
      return data['reportId'].toString();
    }

    throw Exception('Report ID not found in server response');
  }
}

// Custom exceptions for better error handling
class ReportSubmissionException implements Exception {
  final String message;
  final int? statusCode;

  const ReportSubmissionException(this.message, [this.statusCode]);

  @override
  String toString() => 'ReportSubmissionException: $message';
}

class ReportValidationException implements Exception {
  final String message;

  const ReportValidationException(this.message);

  @override
  String toString() => 'ReportValidationException: $message';
}
