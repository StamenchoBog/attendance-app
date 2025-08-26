import 'dart:convert';
import 'package:attendance_app/data/models/room.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoomRepository {
  final ApiClient _apiClient;
  static const String _cacheKey = 'cached_rooms';

  RoomRepository(this._apiClient);

  Future<List<Room>> getRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);

    try {
      // Fetch from API
      final response = await _apiClient.get(ApiEndpoints.rooms);
      final rooms = (response['data'] as List)
          .map((json) => Room.fromJson(json))
          .toList();

      // Cache the new data
      await prefs.setString(_cacheKey, jsonEncode(rooms.map((r) => r.toJson()).toList()));

      return rooms;
    } catch (e) {
      // If API fails, try to use cached data
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((json) => Room.fromJson(json)).toList();
      }

      // If no cache and API fails, rethrow
      if (e is ApiException) {
        throw e.message;
      }
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}