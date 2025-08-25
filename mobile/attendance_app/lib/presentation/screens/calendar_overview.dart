import 'dart:async';
import 'package:attendance_app/data/providers/dashboard_state_provider.dart';
import 'package:attendance_app/presentation/screens/qr_scanner_screen.dart';
import 'package:attendance_app/presentation/widgets/specific/horizontal_day_scroller.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/data/repositories/class_session_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:provider/provider.dart';
// Widgets
import 'package:attendance_app/presentation/widgets/specific/timeline_view.dart';
import 'package:attendance_app/presentation/widgets/static/bottom_nav_bar.dart';
import 'package:attendance_app/presentation/widgets/static/app_top_bar.dart';
import 'package:attendance_app/presentation/widgets/static/timeline_skeleton.dart';

import '../../data/services/api/api_roles.dart';
import '../widgets/specific/class_details_bottom_sheet.dart';

class CalendarOverview extends StatefulWidget {
  const CalendarOverview({super.key});

  @override
  State<CalendarOverview> createState() => _CalendarOverviewState();
}

class _CalendarOverviewState extends State<CalendarOverview> {
  int _selectedIndex = 1;
  DashboardStateProvider? _dashboardStateProvider;
  late DateTime _visibleMonth;
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  String? _errorMessage;

  // --- Timeline Parameters ---
  final int _startHour = 7;
  final double _hourHeight = 60.h;
  final double _timelineLeftPadding = 50.w;

  final ClassSessionRepository _classSessionRepository =
      locator<ClassSessionRepository>();
  bool _isLoading = false;
  List<Map<String, dynamic>> _classes = [];

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
    final user = userProvider.currentUser;

    if (user == null || user is! Student) {
      return [];
    }

    final student = user;
    final studentIndex = student.studentIndex;

    final selectedDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, _startHour);

    List<dynamic> classes = await _classSessionRepository.getClassSessionsByStudentAndDateTime(studentIndex, selectedDateTime);

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

        // Create a new map that is compatible with the timeline
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ColorPalette.darkBlue,
              onPrimary: Colors.white,
              onSurface: ColorPalette.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: ColorPalette.darkBlue),
            ),
          ),
          child: child!,
        );
      },
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
            decoration: BoxDecoration(
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorPalette.darkBlue,
                      side: BorderSide(color: ColorPalette.placeholderGrey),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: Text('Today', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: () => _showMonthPicker(context, dashboardState),
                    icon: const Icon(CupertinoIcons.calendar, color: ColorPalette.darkBlue),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  // Calculate the approximate center of the viewport
                  final centerIndex = (scrollInfo.metrics.pixels + scrollInfo.metrics.viewportDimension / 2) / 65.w;
                  final centerDate = DateTime.now().subtract(const Duration(days: 1)).add(Duration(days: centerIndex.round()));

                  if (centerDate.month != _visibleMonth.month || centerDate.year != _visibleMonth.year) {
                    Future.microtask(() {
                      if (mounted) {
                        setState(() {
                          _visibleMonth = centerDate;
                        });
                      }
                    });
                  }
                  return true;
                },
                child: HorizontalDayScroller(
                  selectedDate: selectedDate,
                  onDateSelected: (date) => dashboardState.updateDate(date),
                ),
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
                                Icon(
                                  CupertinoIcons.exclamationmark_triangle,
                                  size: 50.sp,
                                  color: ColorPalette.iconGrey,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: () => _loadClassSessions(
                                      _dashboardStateProvider!.selectedDate),
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _classes.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.calendar_badge_minus,
                                      size: 50.sp,
                                      color: ColorPalette.iconGrey,
                                    ),
                                    SizedBox(height: 16.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                                      child: Text(
                                        'No classes scheduled for this date.',
                                        style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                child: Stack(
                                  children: [
                                    TimelineView(
                                      events: _classes,
                                      startHour: _startHour,
                                      endHour: 21,
                                      hourHeight: _hourHeight,
                                      timelineLeftPadding: _timelineLeftPadding,
                                      userRole: ApiRoles.studentRole,
                                      onEventTap: (event) {
                                        final user = Provider.of<UserProvider>(context, listen: false).currentUser as Student?;
                                        if (user == null) return;

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
                                                    deviceId: 'dummy-device-id', // TODO: Get real device ID
                                                  ),
                                                ),
                                              );
                                            },
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