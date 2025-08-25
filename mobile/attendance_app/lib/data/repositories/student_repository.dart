import '../services/api/api_client.dart';
import '../services/api/api_endpoints.dart';
import '../../data/models/student.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StudentRepository {
  final ApiClient _apiClient;
  
  StudentRepository(this._apiClient);
  
  Future<List<Student>> getStudents() async {
    try {
      // Try to get from API
      final data = await _apiClient.get(ApiEndpoints.students);
      final students = (data as List).map((json) => Student.fromJson(json)).toList();
      
      // Cache the result
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_students', jsonEncode(
        students.map((student) => student.toJson()).toList()
      ));
      
      return students;
    } catch (e) {
      // If API fails, try to use cached data
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_students');
      
      if (cachedData != null) {
        final List<dynamic> decoded = jsonDecode(cachedData);
        return decoded.map((json) => Student.fromJson(json)).toList();
      }
      
      // If no cache, rethrow the exception
      rethrow;
    }
  }
  
  // Other methods (getStudentById, createStudent, etc.)
}