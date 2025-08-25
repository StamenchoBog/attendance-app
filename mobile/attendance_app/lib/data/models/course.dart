import 'package:json_annotation/json_annotation.dart';

part 'course.g.dart';

@JsonSerializable()
class Course {
  final int id;
  final String studyYear;
  final String semesterCode;
  final String joinedSubjectAbbreviation;
  final String professorId;
  final String assistantId;

  const Course({
    required this.id,
    required this.studyYear,
    required this.semesterCode,
    required this.joinedSubjectAbbreviation,
    required this.professorId,
    required this.assistantId,
  });

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseToJson(this);
}