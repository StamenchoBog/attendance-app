import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'subject.g.dart';

@JsonSerializable()
class Subject extends Equatable {
  final String id;
  final String name;
  final String? nameEn;
  final String? semester;
  final int weeklyLectureClasses;
  final int weeklyAuditoriumClasses;
  final int weeklyLabClasses;
  final String? abbreviation;

  const Subject({
    required this.id,
    required this.name,
    this.nameEn,
    this.semester,
    required this.weeklyLectureClasses,
    required this.weeklyAuditoriumClasses,
    required this.weeklyLabClasses,
    this.abbreviation,
  });

  factory Subject.fromJson(Map<String, dynamic> json) => _$SubjectFromJson(json);

  Map<String, dynamic> toJson() => _$SubjectToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    nameEn,
    semester,
    weeklyLectureClasses,
    weeklyAuditoriumClasses,
    weeklyLabClasses,
    abbreviation,
  ];
}
