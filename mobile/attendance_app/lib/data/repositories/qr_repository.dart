import 'dart:convert';
import 'dart:typed_data';
import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class QRRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'QRRepository';

  QRRepository(this._apiClient);

  Future<Uint8List?> generateQRCode({required int professorClassSessionId, BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<Uint8List>(
      () async {
        final requestBody = {'professorClassSessionId': professorClassSessionId};

        final response = await _apiClient.post<String>(ApiEndpoints.qrGenerateQR, data: requestBody);

        if (response.data != null) {
          return base64Decode(response.data!);
        }

        return Uint8List(0);
      },
      _repositoryName,
      'generateQRCode',
      showDialog: context != null,
      context: context,
    );
  }
}
