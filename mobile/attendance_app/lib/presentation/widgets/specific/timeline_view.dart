import 'package:flutter/material.dart';
import 'package:attendance_app/presentation/widgets/specific/calendar_overview_widgets.dart';

class TimelineView extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final int startHour;
  final int endHour;
  final double hourHeight;
  final double timelineLeftPadding;
  final Function(Map<String, dynamic>) onEventTap;
  final String userRole;

  const TimelineView({
    super.key,
    required this.events,
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.timelineLeftPadding,
    required this.onEventTap,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: (endHour - startHour) * hourHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          buildTimelineLabels(startHour, endHour, hourHeight, timelineLeftPadding),
          buildHourLines(startHour, endHour, hourHeight, timelineLeftPadding),
          buildEventArea(context, events, startHour, endHour, hourHeight, timelineLeftPadding, onEventTap, userRole),
        ],
      ),
    );
  }
}
