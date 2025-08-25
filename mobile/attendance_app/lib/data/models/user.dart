import 'package:json_annotation/json_annotation.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/data/models/professor.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final String role;

  const User({
    required this.id,
    required this.name, 
    required this.email,
    required this.role,
  });

  static User fromJson(Map<String, dynamic> json) {
    final role = json['role'];
    
    if (role == 'STUDENT') {
      return Student.fromJson(json);
    } else if (role == 'PROFESSOR') {
      return Professor.fromJson(json);
    } else {
      throw Exception('Unknown user role: $role');
    }
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
