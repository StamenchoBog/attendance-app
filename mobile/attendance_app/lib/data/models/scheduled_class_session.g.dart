// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_class_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduledClassSession _$ScheduledClassSessionFromJson(
  Map<String, dynamic> json,
) => ScheduledClassSession(
  id: (json['id'] as num).toInt(),
  courseId: (json['courseId'] as num).toInt(),
  roomName: json['roomName'] as String,
  type: json['type'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  dayOfWeek: (json['dayOfWeek'] as num).toInt(),
  semesterCode: json['semesterCode'] as String,
);

Map<String, dynamic> _$ScheduledClassSessionToJson(
  ScheduledClassSession instance,
) => <String, dynamic>{
  'id': instance.id,
  'courseId': instance.courseId,
  'roomName': instance.roomName,
  'type': instance.type,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'dayOfWeek': instance.dayOfWeek,
  'semesterCode': instance.semesterCode,
};
