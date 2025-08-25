import 'dart:async';
import 'package:attendance_app/data/models/professor.dart';
import 'package:attendance_app/data/providers/dashboard_state_provider.dart';
import 'package:attendance_app/presentation/widgets/specific/horizontal_day_scroller.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/data/repositories/class_session_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:provider/provider.dart';
// Widgets
import 'package:attendance_app/presentation/widgets/specific/timeline_view.dart';
import 'package:attendance_app/presentation/widgets/static/bottom_nav_bar.dart';
import 'package:attendance_app/presentation/screens/professor_class_details_screen.dart';
import 'package:attendance_app/presentation/widgets/static/app_top_bar.dart';
import 'package:attendance_app/presentation/widgets/static/timeline_skeleton.dart';

import '../../data/services/api/api_roles.dart';

class ProfessorCalendarOverview extends StatefulWidget {
  const ProfessorCalendarOverview({super.key});

  @override
  State<ProfessorCalendarOverview> createState() => _ProfessorCalendarOverviewState();
}

class _ProfessorCalendarOverviewState extends State<ProfessorCalendarOverview> {
  int _selectedIndex = 1;
  DashboardStateProvider? _dashboardStateProvider;
  late DateTime _visibleMonth;
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  // --- Timeline Parameters ---
  final int _startHour = 7;
  final double _hourHeight = 60.h;
  final double _timelineLeftPadding = 50.w;

  final ClassSessionRepository _classSessionRepository =
      locator<ClassSessionRepository>();
  bool _isLoading = false;
  List<Map<String, dynamic>> _classes = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<DashboardStateProvider>(context);
    if (provider != _dashboardStateProvider) {
      _dashboardStateProvider?.removeListener(_onDashboardStateChanged);
      _dashboardStateProvider = provider;
      _dashboardStateProvider?.addListener(_onDashboardStateChanged);
      // Initial load
      _visibleMonth = _dashboardStateProvider!.selectedDate;
      _loadClassSessions(_dashboardStateProvider!.selectedDate);
    }
  }

  @override
  void dispose() {
    _dashboardStateProvider?.removeListener(_onDashboardStateChanged);
    _timer?.cancel();
    super.dispose();
  }

  void _onDashboardStateChanged() {
    if (mounted) {
      _loadClassSessions(_dashboardStateProvider!.selectedDate);
    }
  }

  Future<void> _loadClassSessions(DateTime date) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final classes = await _getClassSessionsForDay(date);
      if (!mounted) return;
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load classes. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getClassSessionsForDay(DateTime selectedDate) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser as Professor?;

    if (user == null) {
      return [];
    }

    List<dynamic> classes = await _classSessionRepository.getProfessorClassSessions(user.id, selectedDate);

    return classes.map((classData) {
      final startTimeStr = classData['startTime'];
      final endTimeStr = classData['endTime'];

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

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      handleBottomNavigation(context, index);
    }
  }

  Future<void> _showMonthPicker(BuildContext context, DashboardStateProvider provider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null && picked != provider.selectedDate) {
      provider.updateDate(picked);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildCurrentTimeIndicator() {
    final pixelsPerMinute = _hourHeight / 60.0;
    final minutesPastOrigin = (_currentTime.hour * 60 + _currentTime.minute) - (_startHour * 60);
    final topPosition = minutesPastOrigin * pixelsPerMinute;

    if (topPosition < 0) return const SizedBox.shrink();

    return Positioned(
      top: topPosition,
      left: _timelineLeftPadding - 5.w,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5.h,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = Provider.of<DashboardStateProvider>(context);
    final selectedDate = dashboardState.selectedDate;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
              AppTopBar(
                searchHintText: 'Search',
                onSearchChanged: (value) {},
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(_visibleMonth),
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: ColorPalette.textPrimary),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => dashboardState.updateDate(DateTime.now()),
                    child: const Text('Today'),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: () => _showMonthPicker(context, dashboardState),
                    icon: const Icon(CupertinoIcons.calendar, color: ColorPalette.darkBlue),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              HorizontalDayScroller(
                selectedDate: selectedDate,
                onDateSelected: (date) => dashboardState.updateDate(date),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: _isLoading
                    ? const TimelineSkeleton()
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_errorMessage!),
                                ElevatedButton(
                                  onPressed: () => _loadClassSessions(selectedDate),
                                  child: const Text('Retry'),
                                )
                              ],
                            ),
                          )
                        : _classes.isEmpty
                            ? const Center(child: Text('No classes scheduled for this date.'))
                            : SingleChildScrollView(
                                child: Stack(
                                  children: [
                                    TimelineView(
                                      events: _classes,
                                      startHour: _startHour,
                                      endHour: 21,
                                      hourHeight: _hourHeight,
                                      timelineLeftPadding: _timelineLeftPadding,
                                      userRole: ApiRoles.professorRole,
                                      onEventTap: (event) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ProfessorClassDetailsScreen(classData: event),
                                          ),
                                        );
                                      },
                                    ),
                                    if (_isToday(selectedDate))
                                      _buildCurrentTimeIndicator(),
                                  ],
                                ),
                              ),
              ),
              SizedBox(height: 15.h),
            ],
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