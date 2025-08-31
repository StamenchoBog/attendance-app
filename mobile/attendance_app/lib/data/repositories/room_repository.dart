import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:flutter/material.dart';

class RoomRepository {
  final ApiClient _apiClient;
  static const String _repositoryName = 'RoomRepository';

  RoomRepository(this._apiClient);

  Future<List<Map<String, dynamic>>?> getAllRooms({BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<List<Map<String, dynamic>>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.rooms);

        final List<dynamic> roomsList = response.data?['data'] ?? [];
        return roomsList.cast<Map<String, dynamic>>();
      },
      _repositoryName,
      'getAllRooms',
      showDialog: context != null,
      context: context,
    );
  }

  Future<Map<String, dynamic>?> getRoomByName(String roomName, {BuildContext? context}) async {
    return await ErrorHandler.handleRepositoryError<Map<String, dynamic>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.rooms}/$roomName');

        final roomData = response.data?['data'] as Map<String, dynamic>?;
        return roomData ?? {};
      },
      _repositoryName,
      'getRoomByName',
      showDialog: context != null,
      context: context,
    );
  }

  Future<Map<String, dynamic>?> getRoomByLocationDescription(
    String locationDescription, {
    BuildContext? context,
  }) async {
    return await ErrorHandler.handleRepositoryError<Map<String, dynamic>>(
      () async {
        final response = await _apiClient.get<Map<String, dynamic>>(
          '${ApiEndpoints.roomsByLocation}/$locationDescription',
        );

        final roomData = response.data?['data'] as Map<String, dynamic>?;
        return roomData ?? {};
      },
      _repositoryName,
      'getRoomByLocationDescription',
      showDialog: context != null,
      context: context,
    );
  }
}
