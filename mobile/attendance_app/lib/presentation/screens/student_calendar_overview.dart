import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/data/repositories/class_session_repository.dart';
import 'package:attendance_app/data/services/api/api_roles.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/presentation/screens/qr_scanner_screen.dart';
import 'package:attendance_app/presentation/widgets/specific/class_details_bottom_sheet.dart';
import 'package:attendance_app/presentation/widgets/specific/shared_calendar_view.dart';
import 'package:attendance_app/presentation/widgets/dialogs/first_time_device_registration_dialog.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/core/utils/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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

    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final formattedDateTime = dateFormatter.format(selectedDate);

    final classes = await _classSessionRepository.getClassSessionsByStudentIndexForGivenDateAndTime(
      studentIndex: user.studentIndex,
      dateTime: formattedDateTime,
      context: context,
    );

    return classes
            ?.map((classData) {
              try {
                // Parse the time strings from ClassSessionOverview
                final startTimeStr = classData['classStartTime'] as String?;
                final endTimeStr = classData['classEndTime'] as String?;

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

                // Create timeline event using ClassSessionOverview fields
                var timelineEvent = <String, dynamic>{
                  'id': classData['professorClassSessionId'],
                  'professorClassSessionId': classData['professorClassSessionId'],
                  'scheduledClassSessionId': classData['scheduledClassSessionId'],
                  'subjectName': classData['subjectName'],
                  'subjectId': classData['subjectId'],
                  'roomName': classData['classRoomName'],
                  'classRoomName': classData['classRoomName'],
                  'classType': classData['classType'],
                  'professorId': classData['professorId'],
                  'professorName': classData['professorName'],
                  'courseId': classData['courseId'],
                  'classDate': classData['classDate'],
                  'startTime': startTimeStr,
                  'endTime': endTimeStr,
                  'classStartTime': startTimeStr,
                  'classEndTime': endTimeStr,
                  'dateTime': startDateTime,
                  'duration': duration,
                  'title': classData['subjectName'] ?? 'Unknown',
                  'hasClassStarted': classData['hasClassStarted'],
                  'attendanceStatus': classData['attendanceStatus'],
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

  void _onEventTap(BuildContext context, Map<String, dynamic> event) async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser as Student?;
    if (user == null) return;

    // Store context locally to avoid async gap issues
    final localContext = context;

    try {
      // Get current device identifier
      final currentDeviceId = await _deviceIdentifierService.getPlatformSpecificIdentifier();
      if (currentDeviceId == null) {
        if (mounted && localContext.mounted) {
          NotificationHelper.showError(localContext, 'Unable to identify device. Please try again.');
        }
        return;
      }

      // Check if user has a registered device
      final registeredDevice = await _deviceIdentifierService.getRegisteredDevice(user.studentIndex);

      // If no registered device, show device registration dialog (first-time user only)
      if (registeredDevice['id'] == null) {
        if (mounted && localContext.mounted) {
          showDialog(
            context: localContext,
            builder:
                (context) => FirstTimeDeviceRegistrationDialog(
                  studentIndex: user.studentIndex,
                  onSuccess: () {
                    Navigator.of(localContext).pop();
                    // After successful registration, automatically proceed with attendance verification
                    showModalBottomSheet(
                      context: localContext,
                      builder:
                          (_) => ClassDetailsBottomSheet(
                            classData: event,
                            onVerifyAttendance: () {
                              Navigator.of(localContext).pop();
                              fastPush(
                                localContext,
                                QrScannerScreen(studentIndex: user.studentIndex, deviceId: currentDeviceId),
                              );
                            },
                          ),
                    );
                  },
                  onCancel: () {
                    Navigator.of(localContext).pop();
                  },
                ),
          );
        }
        return;
      }

      // Check if current device matches registered device
      if (registeredDevice['id'] != currentDeviceId) {
        if (mounted && localContext.mounted) {
          // Student has a registered device but is using a different one
          // Show error message with option to request device change (not first-time registration)
          NotificationHelper.showError(
            localContext,
            'This device is not registered for attendance. Please use your registered device (${registeredDevice['name']}) or contact your administrator to request a device change.',
          );
        }
        return;
      }

      // Device is registered and matches - proceed with opening modal
      if (mounted && localContext.mounted) {
        showModalBottomSheet(
          context: localContext,
          builder:
              (_) => ClassDetailsBottomSheet(
                classData: event,
                onVerifyAttendance: () {
                  Navigator.of(localContext).pop();
                  fastPush(localContext, QrScannerScreen(studentIndex: user.studentIndex, deviceId: currentDeviceId));
                },
              ),
        );
      }
    } catch (e) {
      if (mounted && localContext.mounted) {
        NotificationHelper.showError(localContext, 'Error checking device registration. Please try again.');
      }
    }
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
            userRole: ApiRoles.studentRole,
            appBarSearchHint: 'Search Classes...',
            fetchClassesForDate: _fetchStudentClasses,
            onEventTap: _onEventTap,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
