import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_app/data/models/room.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';

class RoomRepository {
  final ApiClient _apiClient;
  final Logger _logger = Logger();
  static const String _cacheKey = 'cached_rooms';
  static const String _cacheTimestampKey = 'rooms_cache_timestamp';

  RoomRepository(this._apiClient);

  Future<List<Room>> getRooms() async {
    try {
      // Fetch from API with proper Dio response handling
      final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.rooms);
      final data = response.data?['data'] as List;
      final rooms = data.map((json) => Room.fromJson(json)).toList();

      // Cache the new data
      await _cacheRooms(rooms);

      return rooms;
    } on ApiException catch (e) {
      _logger.w('API failed, trying cache: ${e.message}');
      return await _getCachedRooms();
    } catch (e) {
      _logger.e('Unexpected error getting rooms: $e');
      // Try cache as fallback
      try {
        return await _getCachedRooms();
      } catch (cacheError) {
        _logger.e('Cache also failed: $cacheError');
        throw 'Unable to load rooms. Please check your connection.';
      }
    }
  }

  Future<Room?> getRoomById(String roomId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('${ApiEndpoints.rooms}/$roomId');
      final data = response.data?['data'];
      return data != null ? Room.fromJson(data) : null;
    } on ApiException catch (e) {
      _logger.e('Failed to get room by ID: ${e.message}');
      throw e.message;
    } catch (e) {
      _logger.e('Unexpected error getting room by ID: $e');
      throw 'Unable to load room details.';
    }
  }

  // Private helper methods
  Future<void> _cacheRooms(List<Room> rooms) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final roomsJson = rooms.map((room) => room.toJson()).toList();
      await prefs.setString(_cacheKey, jsonEncode(roomsJson));
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      _logger.w('Failed to cache rooms: $e');
      // Don't throw, caching is optional
    }
  }

  Future<List<Room>> _getCachedRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    final cacheTimestamp = prefs.getInt(_cacheTimestampKey) ?? 0;

    // Check if cache is too old (24 hours)
    final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTimestamp;
    if (cacheAge > 24 * 60 * 60 * 1000) {
      throw 'Cached data is too old';
    }

    if (cachedData != null) {
      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.map((json) => Room.fromJson(json)).toList();
    }

    throw 'No cached rooms available';
  }
}
