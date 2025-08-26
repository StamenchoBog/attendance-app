import 'dart:async';
import 'package:attendance_app/data/providers/date_provider.dart';
import 'package:attendance_app/presentation/widgets/specific/horizontal_day_scroller.dart';
import 'package:attendance_app/presentation/widgets/specific/timeline_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/color_palette.dart';
import '../static/app_top_bar.dart';
import '../static/timeline_skeleton.dart';

class SharedCalendarView extends StatefulWidget {
  final String userRole;
  final Future<List<Map<String, dynamic>>> Function(DateTime) fetchClassesForDate;
  final void Function(BuildContext, Map<String, dynamic>) onEventTap;
  final String appBarSearchHint;

  const SharedCalendarView({
    super.key,
    required this.userRole,
    required this.fetchClassesForDate,
    required this.onEventTap,
    required this.appBarSearchHint,
  });

  @override
  State<SharedCalendarView> createState() => _SharedCalendarViewState();
}

class _SharedCalendarViewState extends State<SharedCalendarView> {
  DateProvider? _dateProvider;
  late DateTime _visibleMonth;
  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  String? _errorMessage;
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _allClasses = [];
  List<Map<String, dynamic>> _filteredClasses = [];
  String _searchQuery = '';

  final int _startHour = 7;
  final double _hourHeight = 60.h;
  final double _timelineLeftPadding = 50.w;

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
    final provider = Provider.of<DateProvider>(context);
    if (provider != _dateProvider) {
      _dateProvider?.removeListener(_onDateChanged);
      _dateProvider = provider;
      _dateProvider?.addListener(_onDateChanged);
      _visibleMonth = _dateProvider!.selectedDate;
      _loadClassSessions(_dateProvider!.selectedDate);
    }
  }

  @override
  void dispose() {
    _dateProvider?.removeListener(_onDateChanged);
    _timer?.cancel();
    super.dispose();
  }

  void _onDateChanged() {
    if (mounted) {
      _loadClassSessions(_dateProvider!.selectedDate);
    }
  }

  Future<void> _loadClassSessions(DateTime date) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final classes = await widget.fetchClassesForDate(date);
      if (!mounted) return;
      setState(() {
        _allClasses = classes;
        _filteredClasses = classes;
        _isLoading = false;
        _filterClasses();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load classes. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _filterClasses() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredClasses = _allClasses;
      });
      return;
    }

    final lowerCaseQuery = _searchQuery.toLowerCase();
    final filtered = _allClasses.where((classData) {
      final subjectName = (classData['title'] as String? ?? '').toLowerCase();
      final roomName = (classData['roomName'] as String? ?? '').toLowerCase();
      
      return subjectName.contains(lowerCaseQuery) ||
             roomName.contains(lowerCaseQuery);
    }).toList();

    setState(() {
      _filteredClasses = filtered;
    });
  }

  Future<void> _showMonthPicker(BuildContext context, DateProvider provider) async {
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
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
          Expanded(child: Container(height: 1.5.h, color: Colors.red)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateState = Provider.of<DateProvider>(context);
    final selectedDate = dateState.selectedDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15.h),
        AppTopBar(
          searchHintText: widget.appBarSearchHint, 
          onSearchChanged: (value) {
            setState(() {
              _searchQuery = value;
              _filterClasses();
            });
          }
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
              onPressed: () => dateState.updateDate(DateTime.now()),
              child: const Text('Today'),
            ),
            SizedBox(width: 8.w),
            IconButton(
              onPressed: () => _showMonthPicker(context, dateState),
              icon: const Icon(CupertinoIcons.calendar, color: ColorPalette.darkBlue),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        HorizontalDayScroller(
          selectedDate: selectedDate,
          onDateSelected: (date) => dateState.updateDate(date),
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
                  : _filteredClasses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isEmpty ? CupertinoIcons.calendar_badge_minus : CupertinoIcons.search_circle, 
                                size: 50.sp, 
                                color: ColorPalette.iconGrey
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                _searchQuery.isEmpty
                                  ? 'No classes scheduled for this date.'
                                  : 'No classes found for "$_searchQuery".'
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Stack(
                            children: [
                              TimelineView(
                                events: _filteredClasses,
                                startHour: _startHour,
                                endHour: 21,
                                hourHeight: _hourHeight,
                                timelineLeftPadding: _timelineLeftPadding,
                                userRole: widget.userRole,
                                onEventTap: (event) => widget.onEventTap(context, event),
                              ),
                              if (_isToday(selectedDate)) _buildCurrentTimeIndicator(),
                            ],
                          ),
                        ),
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}
