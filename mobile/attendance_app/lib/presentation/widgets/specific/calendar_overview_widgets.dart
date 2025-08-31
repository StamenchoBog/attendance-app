import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/data/services/api/api_roles.dart';
import 'package:attendance_app/presentation/screens/qr_scanner_screen.dart';
import 'package:attendance_app/presentation/widgets/specific/class_details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:provider/provider.dart';

Widget buildTimelineLabels(int startHour, int endHour, double hourHeight, double timelineLeftPadding) {
  List<Widget> labels = [];
  for (int hour = startHour; hour < endHour; hour++) {
    labels.add(
      Positioned(
        top: (hour - startHour) * hourHeight - 8.h,
        left: 5.w,
        child: Container(
          height: hourHeight,
          width: timelineLeftPadding - 10.w,
          alignment: Alignment.topCenter,
          child: Text(
            '${hour.toString().padLeft(2, '0')}:00',
            style: TextStyle(fontSize: 12.sp, color: ColorPalette.textSecondary),
          ),
        ),
      ),
    );
  }

  labels.add(
    Positioned(
      top: (endHour - startHour) * hourHeight - 8.h,
      left: 5.w,
      child: Container(
        height: hourHeight,
        width: timelineLeftPadding - 10.w,
        alignment: Alignment.topCenter,
        child: Text(
          '${endHour.toString().padLeft(2, '0')}:00',
          style: TextStyle(fontSize: 12.sp, color: ColorPalette.textSecondary),
        ),
      ),
    ),
  );
  return Stack(children: labels);
}

Widget buildHourLines(int startHour, int endHour, double hourHeight, double timelineLeftPadding) {
  List<Widget> lines = [];
  for (int hour = startHour; hour <= endHour; hour++) {
    lines.add(
      Positioned(
        top: (hour - startHour) * hourHeight,
        left: timelineLeftPadding,
        right: 0,
        child: Divider(thickness: 0.5, height: 0.5, color: Colors.grey[300]),
      ),
    );
  }
  return Stack(children: lines);
}

Widget buildEventArea(
  BuildContext context,
  List<Map<String, dynamic>> events,
  int startHour,
  int endHour,
  double hourHeight,
  double timelineLeftPadding,
  Function(Map<String, dynamic>) onEventTap,
  String userRole,
) {
  List<Widget> eventWidgets = [];
  double pixelsPerMinute = hourHeight / 60.0;

  final validEvents = events.where((event) => event['dateTime'] != null && event['duration'] != null).toList();
  validEvents.sort((a, b) => (a['dateTime'] as DateTime).compareTo(b['dateTime'] as DateTime));

  List<List<Map<String, dynamic>>> overlapGroups = [];
  for (var event in validEvents) {
    bool placed = false;
    for (var group in overlapGroups) {
      final lastEventInGroup = group.last;
      if (event['dateTime'].isBefore(lastEventInGroup['dateTime'].add(lastEventInGroup['duration']))) {
        group.add(event);
        placed = true;
        break;
      }
    }
    if (!placed) {
      overlapGroups.add([event]);
    }
  }

  for (var event in validEvents) {
    final startTime = event['dateTime'] as DateTime;
    final duration = event['duration'] as Duration;
    final endTime = startTime.add(duration);

    if (endTime.hour < startHour || startTime.hour >= endHour) continue;

    final DateTime clampedStart =
        startTime.hour < startHour ? startTime.copyWith(hour: startHour, minute: 0) : startTime;
    final DateTime clampedEnd = endTime.hour >= endHour ? endTime.copyWith(hour: endHour, minute: 0) : endTime;
    final Duration clampedDuration = clampedEnd.difference(clampedStart);

    double startMinutesPastOrigin = (clampedStart.hour * 60 + clampedStart.minute) - (startHour * 60);
    double topPosition = startMinutesPastOrigin * pixelsPerMinute;
    double eventHeight = (clampedDuration.inMinutes * pixelsPerMinute) - 2.h;
    if (eventHeight < 20.h) eventHeight = 20.h;

    int level = 0;
    for (var group in overlapGroups) {
      if (group.contains(event)) {
        level = group.indexOf(event);
        break;
      }
    }

    double indent = level * 12.w;
    double leftPosition = timelineLeftPadding + indent;
    double availableWidth = 1.sw - timelineLeftPadding - 20.w;
    double eventWidth = availableWidth - indent;
    if (eventWidth < 0) eventWidth = 0;

    eventWidgets.add(
      Positioned(
        top: topPosition,
        left: leftPosition,
        height: eventHeight,
        width: eventWidth,
        child: _buildEventItem(context, event, onEventTap, userRole),
      ),
    );
  }

  return Stack(children: eventWidgets);
}

Widget _buildEventItem(
  BuildContext context,
  Map<String, dynamic> event,
  Function(Map<String, dynamic>) onEventTap,
  String userRole,
) {
  final String title = event['title'] ?? 'Unknown';
  final DateTime startTime = event['dateTime'];
  final Duration duration = event['duration'];
  final DateTime endTime = startTime.add(duration);
  final String? attendanceStatus = event['attendanceStatus'];

  bool isStudent = userRole == ApiRoles.studentRole;
  final bool hasPassed = endTime.isBefore(DateTime.now());
  final bool isReadOnly = isStudent && hasPassed;

  // Enhanced color logic based on attendance status
  Color _getEventColor() {
    if (isReadOnly && attendanceStatus == null) return Colors.grey;

    if (attendanceStatus != null) {
      switch (attendanceStatus.toLowerCase()) {
        case 'verified':
        case 'confirmed':
        case 'present':
          return ColorPalette.successColor;
        case 'registered':
        case 'pending':
          return ColorPalette.warningColor;
        case 'absent':
        case 'missed':
          return ColorPalette.errorColor;
        default:
          break;
      }
    }

    return isReadOnly ? Colors.grey : ColorPalette.darkBlue;
  }

  Color _getEventBackgroundColor() {
    if (isReadOnly && attendanceStatus == null) return ColorPalette.cardBackground;

    if (attendanceStatus != null) {
      switch (attendanceStatus.toLowerCase()) {
        case 'verified':
        case 'confirmed':
        case 'present':
          return ColorPalette.successColor.withValues(alpha: 0.1);
        case 'registered':
        case 'pending':
          return ColorPalette.warningColor.withValues(alpha: 0.1);
        case 'absent':
        case 'missed':
          return ColorPalette.errorColor.withValues(alpha: 0.1);
        default:
          break;
      }
    }

    return isReadOnly ? ColorPalette.cardBackground : ColorPalette.lightestBlue.withValues(alpha: 0.9);
  }

  final Color eventColor = _getEventColor();
  final Color backgroundColor = _getEventBackgroundColor();

  return Material(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(4.r),
    child: InkWell(
      onTap: isReadOnly ? null : () => onEventTap(event),
      borderRadius: BorderRadius.circular(4.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(color: eventColor.withValues(alpha: 0.6), width: 0.8.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getAttendanceIcon(attendanceStatus), size: 10.sp, color: eventColor),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: eventColor),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              '${DateFormat('HH:mm').format(startTime)}-${DateFormat('HH:mm').format(endTime)}',
              style: TextStyle(fontSize: 9.sp, color: eventColor.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    ),
  );
}

IconData _getAttendanceIcon(String? attendanceStatus) {
  if (attendanceStatus == null) return CupertinoIcons.bell_fill;

  switch (attendanceStatus.toLowerCase()) {
    case 'verified':
    case 'confirmed':
    case 'present':
      return CupertinoIcons.checkmark_circle_fill;
    case 'registered':
    case 'pending':
      return CupertinoIcons.clock_fill;
    case 'absent':
    case 'missed':
      return CupertinoIcons.xmark_circle_fill;
    default:
      return CupertinoIcons.bell_fill;
  }
}
