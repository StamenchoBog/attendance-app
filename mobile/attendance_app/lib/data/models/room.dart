import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

@JsonSerializable()
class Room extends Equatable {
  final String name;
  final int capacity;
  final String? equipmentDescription;
  final String? locationDescription;
  final String? type;

  const Room({
    required this.name,
    required this.capacity,
    this.equipmentDescription,
    this.locationDescription,
    this.type,
  });

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);

  @override
  List<Object?> get props => [name, capacity, equipmentDescription, locationDescription, type];
}
