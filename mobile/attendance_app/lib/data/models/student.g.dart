// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Student _$StudentFromJson(Map<String, dynamic> json) => Student(
  email: json['email'] as String,
  studentIndex: json['studentIndex'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  parentName: json['parentName'] as String?,
  studyProgramCode: json['studyProgramCode'] as String?,
);

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
  'email': instance.email,
  'studentIndex': instance.studentIndex,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'parentName': instance.parentName,
  'studyProgramCode': instance.studyProgramCode,
};
