import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/models/report_enums.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class ReportRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'ReportRepository';

  ReportRepository(this._apiClient);

  /// POST /reports/submit - Submits a new report
  Future<String?> submitReport({
    required String title,
    required String description,
    required ReportType reportType,
    required ReportPriority priority,
    String? stepsToReproduce,
    required String studentIndex,
    String? deviceId,
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleRepositoryError<String?>(
      () async {
        final requestBody = {
          'title': title,
          'description': description,
          'reportType': reportType.serverValue, // Use serverValue instead of .name
          'priority': priority.serverValue, // Use serverValue instead of .name
          'studentIndex': studentIndex,
          if (stepsToReproduce != null) 'stepsToReproduce': stepsToReproduce,
          if (deviceId != null) 'deviceId': deviceId,
        };

        final response = await _apiClient.post<Map<String, dynamic>>(ApiEndpoints.reportsSubmit, data: requestBody);

        final data = response.data?['data'];
        if (data == null) {
          return null;
        }
        return data.toString();
      },
      _repositoryName,
      'submitReport',
      showDialog: context != null,
      context: context,
    );
  }

  /// GET /reports/all - Gets all reports
  Future<List<Map<String, dynamic>>?> getAllReports({BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<List<Map<String, dynamic>>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.reportsAll);

        final List<dynamic> reportsList = response.data?['data'] ?? [];
        return reportsList.cast<Map<String, dynamic>>();
      },
      _repositoryName,
      'getAllReports',
      showDialog: context != null,
      context: context,
    );
  }

  /// GET /reports/type/{reportType} - Gets reports by type
  Future<List<Map<String, dynamic>>?> getReportsByType(String reportType, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<List<Map<String, dynamic>>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.reportsType}/$reportType');

        // Updated to handle the new API response structure
        final List<dynamic> reportsList = response.data?['data'] ?? [];
        return reportsList.cast<Map<String, dynamic>>();
      },
      _repositoryName,
      'getReportsByType',
      showDialog: context != null,
      context: context,
    );
  }

  /// GET /reports/status/{status} - Gets reports by status
  Future<List<Map<String, dynamic>>?> getReportsByStatus(String status, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<List<Map<String, dynamic>>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.reportsStatus}/$status');

        // Updated to handle the new API response structure
        final List<dynamic> reportsList = response.data?['data'] ?? [];
        return reportsList.cast<Map<String, dynamic>>();
      },
      _repositoryName,
      'getReportsByStatus',
      showDialog: context != null,
      context: context,
    );
  }

  /// GET /reports/count - Gets total report count
  Future<int?> getReportCount({BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<int>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.reportsCount);

        final count = response.data?['data'] as int?;
        return count ?? 0;
      },
      _repositoryName,
      'getReportCount',
      showDialog: context != null,
      context: context,
    );
  }

  /// GET /reports/count/new - Gets new report count
  Future<int?> getNewReportCount({BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<int>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.reportsCountNew);

        // Updated to handle the new API response structure
        final count = response.data?['data'] as int?;
        return count ?? 0;
      },
      _repositoryName,
      'getNewReportCount',
      showDialog: context != null,
      context: context,
    );
  }

  /// PUT /reports/{reportId}/status - Updates report status (admin only)
  Future<Map<String, dynamic>?> updateReportStatus({
    required String reportId,
    required String status,
    String? adminNotes,
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleRepositoryError<Map<String, dynamic>>(
      () async {
        final queryParams = <String, String>{'status': status, if (adminNotes != null) 'adminNotes': adminNotes};

        final response = await _apiClient.put<Map<String, dynamic>>(
          '${ApiEndpoints.reports}/$reportId/status',
          queryParameters: queryParams,
        );

        // Updated to handle the new API response structure
        final reportData = response.data?['data'] as Map<String, dynamic>?;
        return reportData ?? {};
      },
      _repositoryName,
      'updateReportStatus',
      showDialog: context != null,
      context: context,
    );
  }
}
