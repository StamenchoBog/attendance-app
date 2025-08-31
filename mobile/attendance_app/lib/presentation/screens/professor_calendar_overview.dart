import 'package:attendance_app/data/models/professor.dart';
import 'package:attendance_app/data/repositories/class_session_repository.dart';
import 'package:attendance_app/data/services/api/api_roles.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/presentation/screens/professor_class_details_screen.dart';
import 'package:attendance_app/presentation/widgets/specific/shared_calendar_view.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/providers/user_provider.dart';
import '../widgets/static/bottom_nav_bar.dart';

class ProfessorCalendarOverview extends StatefulWidget {
  const ProfessorCalendarOverview({super.key});

  @override
  State<ProfessorCalendarOverview> createState() => _ProfessorCalendarOverviewState();
}

class _ProfessorCalendarOverviewState extends State<ProfessorCalendarOverview> {
  final ClassSessionRepository _classSessionRepository = locator<ClassSessionRepository>();
  int _selectedIndex = 1;

  Future<List<Map<String, dynamic>>> _fetchProfessorClasses(DateTime selectedDate) async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser as Professor?;
    if (user == null) return [];

    final classes = await _classSessionRepository.getProfessorClassSessionsByDate(
      professorId: user.id,
      date: selectedDate,
      context: context,
    );

    return classes
            ?.map((classData) {
              try {
                // Parse time strings from ProfessorClassSession (startTime and endTime are strings)
                final startTimeStr = classData['startTime'] as String?;
                final endTimeStr = classData['endTime'] as String?;

                if (startTimeStr == null || endTimeStr == null) return null;

                final startParts = startTimeStr.split(':');
                final endParts = endTimeStr.split(':');
                if (startParts.length < 2 || endParts.length < 2) return null;

                final startDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  int.parse(startParts[0]),
                  int.parse(startParts[1]),
                );
                final endDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  int.parse(endParts[0]),
                  int.parse(endParts[1]),
                );
                final duration = endDateTime.difference(startDateTime);

                // Create timeline event using ProfessorClassSession fields
                var timelineEvent = <String, dynamic>{
                  'id': classData['professorClassSessionId'],
                  'professorClassSessionId': classData['professorClassSessionId'],
                  'scheduledClassSessionId': classData['scheduledClassSessionId'],
                  'subjectName': classData['subjectName'],
                  'subjectId': classData['subjectId'],
                  'roomName': classData['roomName'],
                  'classType': classData['type'],
                  'startTime': startTimeStr,
                  'endTime': endTimeStr,
                  'date': classData['date'],
                  'dateTime': startDateTime,
                  'duration': duration,
                  'title': classData['subjectName'] ?? 'Unknown',
                };
                return timelineEvent;
              } catch (e) {
                return null;
              }
            })
            .where((item) => item != null)
            .toList()
            .cast<Map<String, dynamic>>() ??
        [];
  }

  void _onEventTap(BuildContext context, Map<String, dynamic> event) {
    fastPush(context, ProfessorClassDetailsScreen(classData: event));
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      handleBottomNavigation(context, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.pureWhite,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
          child: SharedCalendarView(
            userRole: ApiRoles.professorRole,
            appBarSearchHint: 'Search Classes...',
            fetchClassesForDate: _fetchProfessorClasses,
            onEventTap: _onEventTap,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
