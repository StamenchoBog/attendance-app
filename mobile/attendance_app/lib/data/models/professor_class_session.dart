import 'package:json_annotation/json_annotation.dart';

part 'professor_class_session.g.dart';

@JsonSerializable()
class ProfessorClassSession {
  final String professorClassSessionId;
  final String scheduledClassSessionId;
  final String? type;
  final String? roomName;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;

  const ProfessorClassSession({
    required this.professorClassSessionId,
    required this.scheduledClassSessionId,
    this.type,
    this.roomName,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory ProfessorClassSession.fromJson(Map<String, dynamic> json) => _$ProfessorClassSessionFromJson(json);

  Map<String, dynamic> toJson() => _$ProfessorClassSessionToJson(this);
}