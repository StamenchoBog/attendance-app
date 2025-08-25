import 'package:attendance_app/core/services/device_identifier_service.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/data/providers/dashboard_state_provider.dart';
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
  List<dynamic> _classes = [];
  final ClassSessionRepository _classSessionRepository =
      locator<ClassSessionRepository>();
  final DeviceIdentifierService _deviceIdentifierService =
      DeviceIdentifierService();
  DashboardStateProvider? _dashboardStateProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<DashboardStateProvider>(context);
    if (provider != _dashboardStateProvider) {
      _dashboardStateProvider?.removeListener(_loadClasses);
      _dashboardStateProvider = provider;
      _dashboardStateProvider?.addListener(_loadClasses);
      // Initial load
      _loadClasses();
    }
  }

  @override
  void dispose() {
    _dashboardStateProvider?.removeListener(_loadClasses);
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
    final dashboardState = Provider.of<DashboardStateProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dashboardState.selectedDate,
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
    if (picked != null && picked != dashboardState.selectedDate) {
      dashboardState.updateDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final dashboardState = Provider.of<DashboardStateProvider>(context, listen: false);
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: dashboardState.selectedTime,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        }
    );
    if (picked != null && picked != dashboardState.selectedTime) {
      dashboardState.updateTime(picked);
    }
  }

  Future<List<dynamic>> _getClasses() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dashboardState = Provider.of<DashboardStateProvider>(context, listen: false);
    final user = userProvider.currentUser;
    
    if (user == null || user is! Student) {
      _logger.e('No student found or user is not a student');
      return [];
    }
    
    final student = user;
    final studentIndex = student.studentIndex;
    
    final selectedDateTime = DateTime(
      dashboardState.selectedDate.year,
      dashboardState.selectedDate.month,
      dashboardState.selectedDate.day,
      dashboardState.selectedTime.hour,
      dashboardState.selectedTime.minute,
    );
    
    return await _classSessionRepository.getClassSessionsByStudentAndDateTime(
      studentIndex, 
      selectedDateTime
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = Provider.of<DashboardStateProvider>(context);

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
                onSearchChanged: (value) {
                  _logger.i('Search query: $value');
                },
              ),

              SizedBox(height: 15.h),

              buildStudentInfoCard(context),

              SizedBox(height: 15.h),

              Row(
                children: [
                  buildDateTimeChip(
                    DateFormat('MMM d, yy').format(dashboardState.selectedDate),
                    CupertinoIcons.calendar,
                    () => _selectDate(context),
                  ),
                  SizedBox(width: 15.w),
                  buildDateTimeChip(
                    DateFormat('HH:mm').format(DateTime(
                    dashboardState.selectedDate.year, dashboardState.selectedDate.month, dashboardState.selectedDate.day,
                    dashboardState.selectedTime.hour, dashboardState.selectedTime.minute)),
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
                                        'No classes scheduled for the selected time/date.',
                                        style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.only(top: 5.h),
                                itemCount: _classes.length,
                                itemBuilder: (context, index) {
                                  final classData = _classes[index];

                                  return GestureDetector(
                                    onTap: () => _onClassTapped(classData),
                                    child: buildClassListItem(
                                      classData['subjectName'] ?? 'N/A',
                                      classData['classRoomName'] ?? 'N/A',
                                      classData['classStartTime'] ?? 'N/A',
                                      classData['hasClassStarted'] ?? false,
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