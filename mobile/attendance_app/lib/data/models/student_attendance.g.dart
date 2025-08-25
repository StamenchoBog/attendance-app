// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentAttendance _$StudentAttendanceFromJson(Map<String, dynamic> json) {
  final classDate = json['classDate'] == null
      ? null
      : DateTime.parse(json['classDate'] as String);

  DateTime? parseTime(String? timeStr) {
    if (classDate == null || timeStr == null) return null;
    try {
      final timeParts = timeStr.split(':');
      return DateTime(
        classDate.year,
        classDate.month,
        classDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
        timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
      );
    } catch (e) {
      return null;
    }
  }

  return StudentAttendance(
    studentAttendanceId: json['studentAttendanceId'] as String,
    studentIndex: json['studentIndex'] as String?,
    studentName: json['studentName'] as String?,
    studyProgramCode: json['studyProgramCode'] as String?,
    professorId: json['professorId'] as String?,
    professorName: json['professorName'] as String?,
    professorClassSessionId: json['professorClassSessionId'] as String?,
    scheduledClassSessionId: json['scheduledClassSessionId'] as String?,
    courseId: json['courseId'] as String?,
    classDate: classDate,
    classType: json['classType'] as String?,
    classRoomName: json['classRoomName'] as String?,
    classStartTime: parseTime(json['classStartTime'] as String?),
    classEndTime: parseTime(json['classEndTime'] as String?),
    professorArrivalTime: json['professorArrivalTime'] == null
        ? null
        : DateTime.parse(json['professorArrivalTime'] as String),
    studentArrivalTime: json['studentArrivalTime'] == null
        ? null
        : DateTime.parse(json['studentArrivalTime'] as String),
    status: json['status'] as String?,
  );
}

Map<String, dynamic> _$StudentAttendanceToJson(StudentAttendance instance) =>
    <String, dynamic>{
      'studentAttendanceId': instance.studentAttendanceId,
      'studentIndex': instance.studentIndex,
      'studentName': instance.studentName,
      'studyProgramCode': instance.studyProgramCode,
      'professorId': instance.professorId,
      'professorName': instance.professorName,
      'professorClassSessionId': instance.professorClassSessionId,
      'scheduledClassSessionId': instance.scheduledClassSessionId,
      'courseId': instance.courseId,
      'classDate': instance.classDate?.toIso8601String(),
      'classType': instance.classType,
      'classRoomName': instance.classRoomName,
      'classStartTime': instance.classStartTime?.toIso8601String(),
      'classEndTime': instance.classEndTime?.toIso8601String(),
      'professorArrivalTime': instance.professorArrivalTime?.toIso8601String(),
      'studentArrivalTime': instance.studentArrivalTime?.toIso8601String(),
      'status': instance.status,
    };