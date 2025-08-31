import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class PresentationRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'PresentationRepository';

  PresentationRepository(this._apiClient);

  Future<Map<String, dynamic>?> createPresentationSession(int sessionId, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<Map<String, dynamic>>(
      () async {
        final response = await _apiClient.post<Map<String, dynamic>>('${ApiEndpoints.presentation}/$sessionId');

        final presentationData = response.data?['data'] as Map<String, dynamic>?;
        return presentationData ?? {};
      },
      _repositoryName,
      'createPresentationSession',
      showDialog: context != null,
      context: context,
    );
  }
}
