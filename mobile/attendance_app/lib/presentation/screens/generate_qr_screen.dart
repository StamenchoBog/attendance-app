import 'dart:convert';
import 'package:attendance_app/data/providers/date_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:attendance_app/core/services/standardized_qr_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/color_palette.dart';
import '../../data/models/professor.dart';
import '../../data/providers/user_provider.dart';
import '../../data/repositories/class_session_repository.dart';
import '../../data/services/service_starter.dart';
import '../widgets/static/bottom_nav_bar.dart';
import '../widgets/static/helpers/navigation_helpers.dart';

class QuickAttendanceScreen extends StatefulWidget {
  const QuickAttendanceScreen({super.key});

  @override
  State<QuickAttendanceScreen> createState() => _QuickAttendanceScreenState();
}

class _QuickAttendanceScreenState extends State<QuickAttendanceScreen> with TickerProviderStateMixin {
  final int _selectedIndex = 2;
  final Logger _logger = Logger();
  final ClassSessionRepository _classSessionRepository = locator<ClassSessionRepository>();
  final AttendanceRepository _attendanceRepository = locator<AttendanceRepository>();

  DateProvider? _dateProvider;
  List<dynamic> _classes = [];
  dynamic _selectedClass;
  bool _isLoading = true;
  String? _errorMessage;
  String _beaconMode = 'dedicated'; // 'dedicated' or 'phone'

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<DateProvider>(context);
    if (provider != _dateProvider) {
      _dateProvider?.removeListener(_loadClassesForDate);
      _dateProvider = provider;
      _dateProvider?.addListener(_loadClassesForDate);
      // Initial load
      _loadClassesForDate();
    }
  }

  @override
  void dispose() {
    _dateProvider?.removeListener(_loadClassesForDate);
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadClassesForDate() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedClass = null;
      _classes = [];
    });

    try {
      final user = Provider.of<UserProvider>(context, listen: false).currentUser as Professor?;
      if (user == null) throw Exception("Professor not logged in");

      final classes = await _classSessionRepository.getProfessorClassSessions(user.id, _dateProvider!.selectedDate);
      if (!mounted) return;
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to load classes for the selected date.";
        _isLoading = false;
      });
      _logger.e(e);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateProvider.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != dateProvider.selectedDate) {
      dateProvider.updateDate(picked);
    }
  }

  Future<void> _generateAndShowQrCode() async {
    if (_selectedClass == null) return;

    // Use the standardized QR service with the selected beacon mode
    await StandardizedQRService.generateStandardizedQR(
      context: context,
      classData: _selectedClass,
      beaconMode: _beaconMode,
      showBeaconModeSelector: false, // Don't show selector since user already chose
    );
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      handleBottomNavigation(context, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateState = Provider.of<DateProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 15.h),
                  SizedBox(height: 32.h),

                  // Header section with icon and title
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(Icons.qr_code_2_rounded, color: ColorPalette.darkBlue, size: 28.sp),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Attendance',
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w700,
                                color: ColorPalette.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Generate instant attendance codes for your classes',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: ColorPalette.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date selection card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          borderRadius: BorderRadius.circular(16.r),
                          child: Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(Icons.calendar_today_rounded, color: ColorPalette.darkBlue, size: 20.sp),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selected Date',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: ColorPalette.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        DateFormat('EEEE, MMMM d, yyyy').format(dateState.selectedDate),
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: ColorPalette.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: ColorPalette.textSecondary, size: 24.sp),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Class selection card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(Icons.school_rounded, color: ColorPalette.darkBlue, size: 20.sp),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'Select Class Session',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: ColorPalette.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),

                            if (_isLoading)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.h),
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.darkBlue),
                                      ),
                                      SizedBox(height: 16.h),
                                      Text(
                                        'Loading classes...',
                                        style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else if (_errorMessage != null)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.h),
                                  child: Column(
                                    children: [
                                      Icon(Icons.error_outline_rounded, color: Colors.red.shade400, size: 32.sp),
                                      SizedBox(height: 12.h),
                                      Text(
                                        _errorMessage!,
                                        style: TextStyle(fontSize: 14.sp, color: Colors.red.shade600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else if (_classes.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.h),
                                  child: Column(
                                    children: [
                                      Icon(Icons.event_busy_rounded, color: ColorPalette.textSecondary, size: 32.sp),
                                      SizedBox(height: 12.h),
                                      Text(
                                        'No classes scheduled for this date',
                                        style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        _selectedClass != null
                                            ? ColorPalette.darkBlue.withValues(alpha: 0.3)
                                            : Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: DropdownButtonFormField<dynamic>(
                                  value: _selectedClass,
                                  hint: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                                    child: Text(
                                      'Choose a class session',
                                      style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary),
                                    ),
                                  ),
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                  ),
                                  dropdownColor: Colors.white,
                                  selectedItemBuilder: (BuildContext context) {
                                    return _classes.map<Widget>((dynamic classData) {
                                      return Container(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          classData['subjectName'] ?? 'Unknown Subject',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: ColorPalette.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList();
                                  },
                                  items:
                                      _classes.map<DropdownMenuItem<dynamic>>((dynamic classData) {
                                        return DropdownMenuItem<dynamic>(
                                          value: classData,
                                          child: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(vertical: 8.h),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  classData['subjectName'] ?? 'Unknown Subject',
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: ColorPalette.textPrimary,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 4.h),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,
                                                      size: 12.sp,
                                                      color: ColorPalette.textSecondary,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                      '${classData['startTime']} - ${classData['endTime']}',
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: ColorPalette.textSecondary,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    if (classData['roomName'] != null) ...[
                                                      SizedBox(width: 8.w),
                                                      Icon(Icons.room, size: 12.sp, color: ColorPalette.textSecondary),
                                                      SizedBox(width: 4.w),
                                                      Flexible(
                                                        child: Text(
                                                          classData['roomName'],
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: ColorPalette.textSecondary,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (dynamic newValue) {
                                    setState(() {
                                      _selectedClass = newValue;
                                    });
                                  },
                                ),
                              ),

                            // Selected class details section
                            if (_selectedClass != null) ...[
                              SizedBox(height: 16.h),
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: ColorPalette.darkBlue.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: ColorPalette.darkBlue.withValues(alpha: 0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected Class Details',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: ColorPalette.darkBlue,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time_rounded, size: 16.sp, color: ColorPalette.textSecondary),
                                        SizedBox(width: 8.w),
                                        Text(
                                          'Time: ',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                            color: ColorPalette.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          '${_selectedClass['startTime']} - ${_selectedClass['endTime']}',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: ColorPalette.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (_selectedClass['roomName'] != null) ...[
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          Icon(Icons.room_rounded, size: 16.sp, color: ColorPalette.textSecondary),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Room: ',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w500,
                                              color: ColorPalette.textSecondary,
                                            ),
                                          ),
                                          Text(
                                            _selectedClass['roomName'],
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: ColorPalette.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                    if (_selectedClass['classType'] != null) ...[
                                      SizedBox(height: 8.h),
                                      Row(
                                        children: [
                                          Icon(Icons.school_rounded, size: 16.sp, color: ColorPalette.textSecondary),
                                          SizedBox(width: 8.w),
                                          Text(
                                            'Type: ',
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w500,
                                              color: ColorPalette.textSecondary,
                                            ),
                                          ),
                                          Text(
                                            _selectedClass['classType'],
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                              color: ColorPalette.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Beacon Mode Selection Card
                    if (_selectedClass != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(Icons.bluetooth_rounded, color: ColorPalette.darkBlue, size: 20.sp),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Proximity Verification',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: ColorPalette.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),

                              Text(
                                'Choose how students will verify their proximity:',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: ColorPalette.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 12.h),

                              // Dedicated Beacon Option
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _beaconMode == 'dedicated' ? ColorPalette.darkBlue : Colors.grey.shade300,
                                    width: _beaconMode == 'dedicated' ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  color:
                                      _beaconMode == 'dedicated'
                                          ? ColorPalette.darkBlue.withValues(alpha: 0.05)
                                          : Colors.transparent,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => setState(() => _beaconMode = 'dedicated'),
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Row(
                                        children: [
                                          Radio<String>(
                                            value: 'dedicated',
                                            groupValue: _beaconMode,
                                            onChanged: (value) => setState(() => _beaconMode = value!),
                                            activeColor: ColorPalette.darkBlue,
                                          ),
                                          SizedBox(width: 8.w),
                                          Icon(
                                            Icons.router_rounded,
                                            color:
                                                _beaconMode == 'dedicated'
                                                    ? ColorPalette.darkBlue
                                                    : ColorPalette.textSecondary,
                                            size: 24.sp,
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Dedicated Beacon Device',
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        _beaconMode == 'dedicated'
                                                            ? ColorPalette.darkBlue
                                                            : ColorPalette.textPrimary,
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  'Use a physical beacon device in the classroom',
                                                  style: TextStyle(fontSize: 12.sp, color: ColorPalette.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 12.h),

                              // Professor Phone Option
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _beaconMode == 'phone' ? ColorPalette.darkBlue : Colors.grey.shade300,
                                    width: _beaconMode == 'phone' ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  color:
                                      _beaconMode == 'phone'
                                          ? ColorPalette.darkBlue.withValues(alpha: 0.05)
                                          : Colors.transparent,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => setState(() => _beaconMode = 'phone'),
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Row(
                                        children: [
                                          Radio<String>(
                                            value: 'phone',
                                            groupValue: _beaconMode,
                                            onChanged: (value) => setState(() => _beaconMode = value!),
                                            activeColor: ColorPalette.darkBlue,
                                          ),
                                          SizedBox(width: 8.w),
                                          Icon(
                                            Icons.phone_android_rounded,
                                            color:
                                                _beaconMode == 'phone'
                                                    ? ColorPalette.darkBlue
                                                    : ColorPalette.textSecondary,
                                            size: 24.sp,
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Use This Phone as Beacon',
                                                  style: TextStyle(
                                                    fontSize: 15.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        _beaconMode == 'phone'
                                                            ? ColorPalette.darkBlue
                                                            : ColorPalette.textPrimary,
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  'Turn your phone into a classroom beacon',
                                                  style: TextStyle(fontSize: 12.sp, color: ColorPalette.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              if (_beaconMode == 'phone') ...[
                                SizedBox(height: 16.h),
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.orange, size: 16.sp),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          'Keep this phone in the classroom during attendance',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.orange.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    // Generate button
                    if (_selectedClass != null && _beaconMode.isNotEmpty) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: _generateAndShowQrCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorPalette.darkBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_2_rounded, size: 24.sp),
                              SizedBox(width: 12.w),
                              Text('Generate QR Code', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Extra bottom padding for better scrolling
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
