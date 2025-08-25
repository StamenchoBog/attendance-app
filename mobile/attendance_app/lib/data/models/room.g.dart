// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Room _$RoomFromJson(Map<String, dynamic> json) => Room(
  name: json['name'] as String,
  capacity: (json['capacity'] as num).toInt(),
  equipmentDescription: json['equipmentDescription'] as String?,
  locationDescription: json['locationDescription'] as String?,
  type: json['type'] as String?,
);

Map<String, dynamic> _$RoomToJson(Room instance) => <String, dynamic>{
  'name': instance.name,
  'capacity': instance.capacity,
  'equipmentDescription': instance.equipmentDescription,
  'locationDescription': instance.locationDescription,
  'type': instance.type,
};
