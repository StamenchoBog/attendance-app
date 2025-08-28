import 'package:attendance_app/presentation/screens/generate_qr_screen.dart';
import 'package:attendance_app/presentation/screens/professor_calendar_overview.dart';
import 'package:attendance_app/presentation/screens/submit_report_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/data/services/api/api_roles.dart';
import 'package:attendance_app/presentation/screens/student_dashboard.dart';
import 'package:attendance_app/presentation/screens/student_calendar_overview.dart';
import 'package:attendance_app/presentation/screens/verify_attendance.dart';
import 'package:attendance_app/presentation/screens/profile_overview.dart';
import 'package:attendance_app/presentation/screens/settings/language_setting.dart';
import 'package:attendance_app/presentation/screens/settings/devices_setting.dart';
import '../../../screens/professor_dashboard.dart';

///
/// Fast page transition for responsive app feel
///
class FastPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final RouteSettings? routeSettings;

  FastPageRoute({required this.page, this.routeSettings})
    : super(
        settings: routeSettings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 150),
        // Fast transition
        reverseTransitionDuration: const Duration(milliseconds: 150),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Quick fade transition for responsive feel
          return FadeTransition(opacity: animation, child: child);
        },
      );
}

///
/// Helper methods for fast navigation
///
void fastPush(BuildContext context, Widget page) {
  Navigator.push(context, FastPageRoute(page: page));
}

void fastPushReplacement(BuildContext context, Widget page) {
  Navigator.pushReplacement(context, FastPageRoute(page: page));
}

void fastPushAndRemoveUntil(BuildContext context, Widget page) {
  Navigator.pushAndRemoveUntil(context, FastPageRoute(page: page), (route) => false);
}

///
/// Method for handling bottom navigation bar clicking and redirection (updated with fast transitions)
///
void handleBottomNavigation(BuildContext context, int index) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  switch (index) {
    case 0:
      {
        if (userProvider.currentUser?.role == ApiRoles.studentRole) {
          fastPushReplacement(context, const StudentDashboard());
        } else if (userProvider.currentUser?.role == ApiRoles.professorRole) {
          fastPushReplacement(context, const ProfessorDashboard());
        }
        break;
      }
    case 1:
      if (userProvider.currentUser?.role == ApiRoles.studentRole) {
        fastPush(context, const CalendarOverview());
      } else if (userProvider.currentUser?.role == ApiRoles.professorRole) {
        fastPush(context, const ProfessorCalendarOverview());
      }
      break;
    case 2:
      if (userProvider.currentUser?.role == ApiRoles.studentRole) {
        fastPush(context, const VerifyAttendanceScreen());
      } else if (userProvider.currentUser?.role == ApiRoles.professorRole) {
        fastPush(context, const QuickAttendanceScreen());
      }
      break;
    case 3:
      fastPush(context, const ProfileOverviewScreen());
  }
}

// Method for handling settings list in `profile_overview.dart` (updated with fast transitions)
void navigateToSetting(BuildContext context, String settingName) {
  if (settingName == "languages") {
    fastPush(context, const LanguageSettingsScreen());
  } else if (settingName == "devices") {
    fastPush(context, const DevicesOverviewScreen());
  } else if (settingName == "report_a_problem") {
    fastPush(context, const SubmitReportScreen());
  }
}
