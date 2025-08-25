// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'professor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Professor _$ProfessorFromJson(Map<String, dynamic> json) => Professor(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  title: json['title'] as String,
  orderingRank: (json['orderingRank'] as num).toInt(),
  officeName: json['officeName'] as String?,
);

Map<String, dynamic> _$ProfessorToJson(Professor instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'title': instance.title,
  'orderingRank': instance.orderingRank,
  'officeName': instance.officeName,
};
