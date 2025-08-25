import 'package:attendance_app/data/models/room.dart'; // Assuming you have a Room model
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';

class RoomRepository {
  final ApiClient _apiClient;

  RoomRepository(this._apiClient);

  Future<List<Room>> getRooms() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.rooms);
      return (response['data'] as List)
          .map((json) => Room.fromJson(json))
          .toList();
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}