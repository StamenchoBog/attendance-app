import 'package:attendance_app/core/services/device_identifier_service.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/data/providers/date_provider.dart';
import 'package:attendance_app/data/providers/time_provider.dart';
import 'package:attendance_app/presentation/screens/qr_scanner_screen.dart';
import 'package:attendance_app/presentation/widgets/specific/class_details_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:logger/logger.dart';
// Widgets
import 'package:attendance_app/presentation/widgets/static/app_top_bar.dart';
import 'package:attendance_app/presentation/widgets/static/bottom_nav_bar.dart';
import 'package:attendance_app/presentation/widgets/specific/main_dashboard_widgets.dart';
// Repositories
import 'package:attendance_app/data/repositories/class_session_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/presentation/widgets/static/dashboard_skeleton.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  static final Logger _logger = Logger();

  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  
  List<dynamic> _allClasses = [];
  List<dynamic> _filteredClasses = [];
  String _searchQuery = '';

  final ClassSessionRepository _classSessionRepository =
      locator<ClassSessionRepository>();
  final DeviceIdentifierService _deviceIdentifierService =
      DeviceIdentifierService();
  DateProvider? _dateProvider;
  TimeProvider? _timeProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dateProvider = Provider.of<DateProvider>(context);
    final timeProvider = Provider.of<TimeProvider>(context);

    if (dateProvider != _dateProvider || timeProvider != _timeProvider) {
      _dateProvider?.removeListener(_loadClasses);
      _timeProvider?.removeListener(_loadClasses);
      
      _dateProvider = dateProvider;
      _timeProvider = timeProvider;

      _dateProvider?.addListener(_loadClasses);
      _timeProvider?.addListener(_loadClasses);
      
      // Initial load
      _loadClasses();
    }
  }

  @override
  void dispose() {
    _dateProvider?.removeListener(_loadClasses);
    _timeProvider?.removeListener(_loadClasses);
    super.dispose();
  }

  Future<void> _loadClasses() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final classes = await _getClasses();
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
      final subjectName = (classData['subjectName'] as String? ?? '').toLowerCase();
      final roomName = (classData['classRoomName'] as String? ?? '').toLowerCase();
      final professorName = (classData['professorName'] as String? ?? '').toLowerCase();
      
      return subjectName.contains(lowerCaseQuery) ||
             roomName.contains(lowerCaseQuery) ||
             professorName.contains(lowerCaseQuery);
    }).toList();

    setState(() {
      _filteredClasses = filtered;
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      handleBottomNavigation(context, index);
    }
  }

  void _onClassTapped(Map<String, dynamic> classData) async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser as Student?;
    if (user == null) return;

    final deviceId = await _deviceIdentifierService.getOrGenerateAppSpecificUuid();
    if (deviceId == null) {
      // Handle error case where device ID couldn't be retrieved
      _logger.e("Device ID could not be retrieved.");
      // Optionally show a snackbar to the user
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => ClassDetailsBottomSheet(
        classData: classData,
        onVerifyAttendance: () {
          Navigator.of(context).pop(); // Close the bottom sheet
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

  Future<void> _selectDate(BuildContext context) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateProvider.selectedDate,
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
              style: TextButton.styleFrom(
                foregroundColor: ColorPalette.darkBlue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != dateProvider.selectedDate) {
      dateProvider.updateDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: timeProvider.selectedTime,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        }
    );
    if (picked != null && picked != timeProvider.selectedTime) {
      timeProvider.updateTime(picked);
    }
  }

  Future<List<dynamic>> _getClasses() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final user = userProvider.currentUser;
    
    if (user == null || user is! Student) {
      _logger.e('No student found or user is not a student');
      return [];
    }
    
    final student = user;
    final studentIndex = student.studentIndex;
    
    final selectedDateTime = DateTime(
      dateProvider.selectedDate.year,
      dateProvider.selectedDate.month,
      dateProvider.selectedDate.day,
      timeProvider.selectedTime.hour,
      timeProvider.selectedTime.minute,
    );
    
    return await _classSessionRepository.getClassSessionsByStudentAndDateTime(
      studentIndex, 
      selectedDateTime
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateState = Provider.of<DateProvider>(context);
    final timeState = Provider.of<TimeProvider>(context);

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
                searchHintText: 'Search by subject, room, professor...',
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filterClasses();
                  });
                },
              ),

              SizedBox(height: 15.h),

              buildStudentInfoCard(context),

              SizedBox(height: 15.h),

              Row(
                children: [
                  buildDateTimeChip(
                    DateFormat('MMM d, yy').format(dateState.selectedDate),
                    CupertinoIcons.calendar,
                    () => _selectDate(context),
                  ),
                  SizedBox(width: 15.w),
                  buildDateTimeChip(
                    DateFormat('HH:mm').format(DateTime(
                    dateState.selectedDate.year, dateState.selectedDate.month, dateState.selectedDate.day,
                    timeState.selectedTime.hour, timeState.selectedTime.minute)),
                    CupertinoIcons.clock,
                  () => _selectTime(context),
                  ),
                   const Spacer(),
                ],
              ),

              SizedBox(height: 10.h),

              Expanded(
                child: _isLoading
                    ? const DashboardSkeleton()
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
                                  onPressed: _loadClasses,
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _filteredClasses.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.search_circle,
                                      size: 50.sp,
                                      color: ColorPalette.iconGrey,
                                    ),
                                    SizedBox(height: 16.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                                      child: Text(
                                        _searchQuery.isEmpty
                                          ? 'No classes scheduled for the selected time/date.'
                                          : 'No classes found for "$_searchQuery".',
                                        style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.only(top: 5.h),
                                itemCount: _filteredClasses.length,
                                itemBuilder: (context, index) {
                                  final classData = _filteredClasses[index];
                                  final now = DateTime.now();
                                  final startTimeString = classData['classStartTime'] as String?;
                                  final endTimeString = classData['classEndTime'] as String?;
                                  bool isOngoing = false;

                                  if (startTimeString != null && endTimeString != null) {
                                    try {
                                      final startParts = startTimeString.split(':');
                                      final endParts = endTimeString.split(':');
                                      final selectedDate = dateState.selectedDate;

                                      final classStartDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, int.parse(startParts[0]), int.parse(startParts[1]));
                                      final classEndDateTime = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, int.parse(endParts[0]), int.parse(endParts[1]));
                                      
                                      isOngoing = now.isAfter(classStartDateTime) && now.isBefore(classEndDateTime);
                                    } catch (e) {
                                      _logger.e("Error parsing class time: $e");
                                    }
                                  }

                                  return GestureDetector(
                                    onTap: () => _onClassTapped(classData),
                                    child: buildClassListItem(
                                      classData['subjectName'] ?? 'N/A',
                                      classData['classRoomName'] ?? 'N/A',
                                      classData['classStartTime'] ?? 'N/A',
                                      isOngoing,
                                    ),
                                  );
                                },
                              ),
              ),
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