import 'package:attendance_app/presentation/screens/generate_qr_screen.dart';
import 'package:attendance_app/presentation/screens/professor_calendar_overview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/data/services/api/api_roles.dart';
import 'package:attendance_app/presentation/screens/student_dashboard.dart';
import 'package:attendance_app/presentation/screens/calendar_overview.dart';
import 'package:attendance_app/presentation/screens/verify_attendance.dart';
import 'package:attendance_app/presentation/screens/profile_overview.dart';
import 'package:attendance_app/presentation/screens/settings/language_setting.dart';
import 'package:attendance_app/presentation/screens/settings/devices_setting.dart';
import 'package:attendance_app/presentation/screens/settings/report_a_problem_setting.dart';

import '../../../screens/professor_dashboard.dart';

///
/// Method for handling bottom navigation bar clicking and redirection
///
void handleBottomNavigation(BuildContext context, int index) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  switch (index) {
    case 0:
      {
        if (userProvider.currentUser?.role == ApiRoles.studentRole) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StudentDashboard()),
          );
        } else if (userProvider.currentUser?.role == ApiRoles.professorRole) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfessorDashboard()),
          );
        }
        break;
      }
    case 1:
      if (userProvider.currentUser?.role == ApiRoles.studentRole) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CalendarOverview()),
        );
      } else if (userProvider.currentUser?.role == ApiRoles.professorRole) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ProfessorCalendarOverview()),
        );
      }
      break;
    case 2:
      if (userProvider.currentUser?.role == ApiRoles.studentRole) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VerifyAttendanceScreen()),
        );
      } else if (userProvider.currentUser?.role == ApiRoles.professorRole) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GenerateQrScreen()),
        );
      }
      break;
    case 3:
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ProfileOverviewScreen()));
  }
}

// Method for handling settings list in `profile_overview.dart`
void navigateToSetting(BuildContext context, String settingName) {
  if (settingName == "languages") {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const LanguageSettingsScreen()));
  } else if (settingName == "devices") {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const DevicesOverviewScreen()));
  } else if (settingName == "report_a_problem") {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const ReportProblemScreen()));
  }
}