import 'package:attendance_app/data/models/professor.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';

class ProfessorRepository {
  final ApiClient _apiClient;

  ProfessorRepository(this._apiClient);

  Future<List<Professor>> getProfessors() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.professors);
      return (response['data'] as List)
          .map((json) => Professor.fromJson(json))
          .toList();
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  Future<Professor> getProfessorById(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.professors}/$id');
      return Professor.fromJson(response['data']);
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}