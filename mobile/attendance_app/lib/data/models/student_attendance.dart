import 'package:json_annotation/json_annotation.dart';

part 'student_attendance.g.dart';

@JsonSerializable()
class StudentAttendance {
  final String studentAttendanceId;
  final String? studentIndex;
  final String? studentName;
  final String? studyProgramCode;
  final String? professorId;
  final String? professorName;
  final String? professorClassSessionId;
  final String? scheduledClassSessionId;
  final String? courseId;
  final DateTime? classDate;
  final String? classType;
  final String? classRoomName;
  final DateTime? classStartTime;
  final DateTime? classEndTime;
  final DateTime? professorArrivalTime;
  final DateTime? studentArrivalTime;
  final String? status;

  const StudentAttendance({
    required this.studentAttendanceId,
    this.studentIndex,
    this.studentName,
    this.studyProgramCode,
    this.professorId,
    this.professorName,
    this.professorClassSessionId,
    this.scheduledClassSessionId,
    this.courseId,
    this.classDate,
    this.classType,
    this.classRoomName,
    this.classStartTime,
    this.classEndTime,
    this.professorArrivalTime,
    this.studentArrivalTime,
    this.status,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) => _$StudentAttendanceFromJson(json);

  Map<String, dynamic> toJson() => _$StudentAttendanceToJson(this);
}
