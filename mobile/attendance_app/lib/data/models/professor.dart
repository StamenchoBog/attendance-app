import 'user.dart';
import 'package:attendance_app/data/services/api/api_roles.dart';
import 'package:json_annotation/json_annotation.dart';

part 'professor.g.dart';

@JsonSerializable()
class Professor extends User {
  final String title;
  final int orderingRank;
  final String? officeName;

  const Professor({
    required super.id,
    required super.name,
    required super.email,
    required this.title,
    required this.orderingRank,
    this.officeName,
  }) : super(
    role: ApiRoles.professorRole
  );

  factory Professor.fromJson(Map<String, dynamic> json) => _$ProfessorFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ProfessorToJson(this);
}