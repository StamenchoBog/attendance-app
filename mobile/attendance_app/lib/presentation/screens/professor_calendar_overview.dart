import 'package:attendance_app/data/models/professor.dart';
import 'package:attendance_app/data/repositories/class_session_repository.dart';
import 'package:attendance_app/data/services/api/api_roles.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/presentation/screens/professor_class_details_screen.dart';
import 'package:attendance_app/presentation/widgets/specific/shared_calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/providers/user_provider.dart';
import '../widgets/static/bottom_nav_bar.dart';
import '../widgets/static/helpers/navigation_helpers.dart';

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

    final classes = await _classSessionRepository.getProfessorClassSessions(user.id, selectedDate);

    return classes
        .map((classData) {
          final startTimeStr = classData['startTime'];
          final endTimeStr = classData['endTime'];
          if (startTimeStr == null || endTimeStr == null) return null;

          final startParts = startTimeStr.split(':');
          final endParts = endTimeStr.split(':');
          if (startParts.length < 2 || endParts.length < 2) return null;

          try {
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

            var timelineEvent = Map<String, dynamic>.from(classData);
            timelineEvent['dateTime'] = startDateTime;
            timelineEvent['duration'] = duration;
            timelineEvent['title'] = classData['subjectName'] ?? 'Unknown';
            return timelineEvent;
          } catch (e) {
            return null;
          }
        })
        .where((item) => item != null)
        .toList()
        .cast<Map<String, dynamic>>();
  }

  void _onEventTap(BuildContext context, Map<String, dynamic> event) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfessorClassDetailsScreen(classData: event)));
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
