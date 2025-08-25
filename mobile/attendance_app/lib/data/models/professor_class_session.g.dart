// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professor_class_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfessorClassSession _$ProfessorClassSessionFromJson(
  Map<String, dynamic> json,
) => ProfessorClassSession(
  professorClassSessionId: json['professorClassSessionId'] as String,
  scheduledClassSessionId: json['scheduledClassSessionId'] as String,
  type: json['type'] as String?,
  roomName: json['roomName'] as String?,
  date: DateTime.parse(json['date'] as String),
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
);

Map<String, dynamic> _$ProfessorClassSessionToJson(
  ProfessorClassSession instance,
) => <String, dynamic>{
  'professorClassSessionId': instance.professorClassSessionId,
  'scheduledClassSessionId': instance.scheduledClassSessionId,
  'type': instance.type,
  'roomName': instance.roomName,
  'date': instance.date.toIso8601String(),
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
};
