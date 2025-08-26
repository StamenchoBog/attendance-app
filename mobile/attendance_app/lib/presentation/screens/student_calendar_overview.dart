import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/data/repositories/class_session_repository.dart';
import 'package:attendance_app/data/services/api/api_roles.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/presentation/screens/qr_scanner_screen.dart';
import 'package:attendance_app/presentation/widgets/specific/class_details_bottom_sheet.dart';
import 'package:attendance_app/presentation/widgets/specific/shared_calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/device_identifier_service.dart';
import '../../data/providers/user_provider.dart';
import '../widgets/static/bottom_nav_bar.dart';
import '../widgets/static/helpers/navigation_helpers.dart';

class CalendarOverview extends StatefulWidget {
  const CalendarOverview({super.key});

  @override
  State<CalendarOverview> createState() => _CalendarOverviewState();
}

class _CalendarOverviewState extends State<CalendarOverview> {
  final ClassSessionRepository _classSessionRepository = locator<ClassSessionRepository>();
  final DeviceIdentifierService _deviceIdentifierService = DeviceIdentifierService();
  int _selectedIndex = 1;

  Future<List<Map<String, dynamic>>> _fetchStudentClasses(DateTime selectedDate) async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser as Student?;
    if (user == null) return [];

    // The student endpoint requires a DateTime, so we'll just use the beginning of the day
    final selectedDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final classes = await _classSessionRepository.getClassSessionsByStudentAndDateTime(user.studentIndex, selectedDateTime);

    return classes.map((classData) {
      final startTimeStr = classData['classStartTime'];
      final endTimeStr = classData['classEndTime'];
      if (startTimeStr == null || endTimeStr == null) return null;

      final startParts = startTimeStr.split(':');
      final endParts = endTimeStr.split(':');
      if (startParts.length < 2 || endParts.length < 2) return null;

      try {
        final startDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, int.parse(startParts[0]), int.parse(startParts[1]));
        final endDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, int.parse(endParts[0]), int.parse(endParts[1]));
        final duration = endDateTime.difference(startDateTime);

        var timelineEvent = Map<String, dynamic>.from(classData);
        timelineEvent['dateTime'] = startDateTime;
        timelineEvent['duration'] = duration;
        timelineEvent['title'] = classData['subjectName'] ?? 'Unknown';
        return timelineEvent;
      } catch (e) {
        return null;
      }
    }).where((item) => item != null).toList().cast<Map<String, dynamic>>();
  }

  void _onEventTap(BuildContext context, Map<String, dynamic> event) async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser as Student?;
    if (user == null) return;

    final deviceId = await _deviceIdentifierService.getOrGenerateAppSpecificUuid();
    if (deviceId == null) {
        // Handle error case where device ID couldn't be retrieved
        return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => ClassDetailsBottomSheet(
        classData: event,
        onVerifyAttendance: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => QrScannerScreen(
                studentIndex: user.studentIndex,
                deviceId: deviceId,
              ),
            ),
          );
        },
      ),
    );
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
            userRole: ApiRoles.studentRole,
            appBarSearchHint: 'Search Classes...',
            fetchClassesForDate: _fetchStudentClasses,
            onEventTap: _onEventTap,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
