class ApiEndpoints {
  // Authentication endpoints
  static const String auth = '/auth';
  static const String login = '$auth/login';
  static const String logout = '$auth/logout';
  static const String refresh = '$auth/refresh';

  // Student endpoints
  static const String students = '/students';
  static const String studentsByProfessor = '$students/by-professor';
  static const String studentsIsValid = '$students/is-valid';
  static const String studentsGroups = '$students/groups';
  static const String studentsGroupsByName = '$studentsGroups/name';

  // Professor endpoints
  static const String professors = '/professors';

  // Course endpoints
  static const String courses = '/courses';

  // Subject endpoints
  static const String subjects = '/subjects';
  static const String subjectsByProfessor = '$subjects/by-professor';

  // Room endpoints
  static const String rooms = '/rooms';
  static const String roomsByLocation = '$rooms/by-location';

  // Class session endpoints
  static const String classSessions = '/class-sessions';
  static const String classSessionsByProfessor = '$classSessions/by-professor';
  static const String classSessionsByProfessorByDate = '$classSessionsByProfessor/by-date';
  static const String classSessionsByProfessorCurrentWeek =
      classSessionsByProfessor; // Will append /{professorId}/current-week
  static const String classSessionsByProfessorCurrentMonth =
      classSessionsByProfessor; // Will append /{professorId}/current-month
  static const String classSessionsByStudent = '$classSessions/by-student';
  static const String classSessionsByStudentByDateOverview = '$classSessionsByStudent/by-date/overview';

  // Attendance endpoints
  static const String attendance = '/attendance';
  static const String attendanceRegister = '$attendance/register';
  static const String attendanceConfirm = '$attendance/confirm';
  static const String attendanceVerifyProximity = '$attendance/verify-proximity';
  static const String attendanceLogProximityDetection = '$attendance/log-proximity-detection';
  static const String attendanceLecture = '$attendance/lecture';
  static const String attendanceByStudent = '$attendance/by-student';
  static const String attendanceProximityAnalytics = '$attendance/proximity-analytics';

  // Report endpoints
  static const String reports = '/reports';
  static const String reportsSubmit = '$reports/submit';
  static const String reportsAll = '$reports/all';
  static const String reportsType = '$reports/type';
  static const String reportsStatus = '$reports/status';
  static const String reportsCount = '$reports/count';
  static const String reportsCountNew = '$reportsCount/new';

  // QR service endpoints
  static const String qr = '/qr';
  static const String qrGenerateQR = '$qr/generateQR';

  // Semester endpoints
  static const String semesters = '/semesters';

  // Presentation endpoints
  static const String presentation = '/presentation';

  // Web controller endpoints (for presentations)
  static const String p = '/p';
}
