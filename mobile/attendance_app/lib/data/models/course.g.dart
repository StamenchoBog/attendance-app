// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Course _$CourseFromJson(Map<String, dynamic> json) => Course(
  id: (json['id'] as num).toInt(),
  studyYear: json['studyYear'] as String,
  semesterCode: json['semesterCode'] as String,
  joinedSubjectAbbreviation: json['joinedSubjectAbbreviation'] as String,
  professorId: json['professorId'] as String,
  assistantId: json['assistantId'] as String,
);

Map<String, dynamic> _$CourseToJson(Course instance) => <String, dynamic>{
  'id': instance.id,
  'studyYear': instance.studyYear,
  'semesterCode': instance.semesterCode,
  'joinedSubjectAbbreviation': instance.joinedSubjectAbbreviation,
  'professorId': instance.professorId,
  'assistantId': instance.assistantId,
};
