import 'user.dart';
import 'package:attendance_app/data/services/api/api_roles.dart';
import 'package:json_annotation/json_annotation.dart';

part 'student.g.dart';

@JsonSerializable()
class Student extends User {
  final String studentIndex;
  final String firstName;
  final String lastName;
  final String? parentName;
  final String? studyProgramCode;

  const Student({
    required super.email,
    required this.studentIndex,
    required this.firstName,
    required this.lastName,
    this.parentName,
    this.studyProgramCode,
  }) : super(
    id: studentIndex,
    name: "$firstName $lastName",
    role: ApiRoles.studentRole
  );

  factory Student.fromJson(Map<String, dynamic> json) => _$StudentFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StudentToJson(this);
}