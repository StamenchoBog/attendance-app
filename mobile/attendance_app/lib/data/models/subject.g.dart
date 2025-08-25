// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => Subject(
  id: json['id'] as String,
  name: json['name'] as String,
  nameEn: json['nameEn'] as String?,
  semester: json['semester'] as String?,
  weeklyLectureClasses: (json['weeklyLectureClasses'] as num).toInt(),
  weeklyAuditoriumClasses: (json['weeklyAuditoriumClasses'] as num).toInt(),
  weeklyLabClasses: (json['weeklyLabClasses'] as num).toInt(),
  abbreviation: json['abbreviation'] as String?,
);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nameEn': instance.nameEn,
  'semester': instance.semester,
  'weeklyLectureClasses': instance.weeklyLectureClasses,
  'weeklyAuditoriumClasses': instance.weeklyAuditoriumClasses,
  'weeklyLabClasses': instance.weeklyLabClasses,
  'abbreviation': instance.abbreviation,
};
