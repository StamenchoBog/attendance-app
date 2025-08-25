import 'package:json_annotation/json_annotation.dart';

part 'scheduled_class_session.g.dart';

@JsonSerializable()
class ScheduledClassSession {
  final int id;
  final int courseId;
  final String roomName;
  final String type;
  final DateTime startTime;
  final DateTime endTime;
  final int dayOfWeek;
  final String semesterCode;

  const ScheduledClassSession({
    required this.id,
    required this.courseId,
    required this.roomName,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.semesterCode,
  });

  factory ScheduledClassSession.fromJson(Map<String, dynamic> json) =>
      _$ScheduledClassSessionFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduledClassSessionToJson(this);
}