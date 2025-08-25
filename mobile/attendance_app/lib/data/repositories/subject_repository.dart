import 'package:attendance_app/data/models/subject.dart';
import 'package:attendance_app/data/services/api/api_client.dart';
import 'package:attendance_app/data/services/api/api_endpoints.dart';

class SubjectRepository {
  final ApiClient _apiClient;

  SubjectRepository(this._apiClient);

  Future<List<Subject>> getSubjectsByProfessorId(String professorId) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.subjects}/by-professor/$professorId');
      return (response['data'] as List)
          .map((json) => Subject.fromJson(json))
          .toList();
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }
}