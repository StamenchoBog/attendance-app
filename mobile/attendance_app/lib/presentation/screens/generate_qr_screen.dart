import 'package:attendance_app/data/providers/date_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:attendance_app/core/services/standardized_qr_service.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/ui_helpers.dart';
import '../../core/constants/app_constants.dart';
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

      // Use date-based endpoint instead of current-week
      final selectedDate = _dateProvider?.selectedDate ?? DateTime.now();
      final classes = await _classSessionRepository.getProfessorClassSessionsByDate(
        professorId: user.id,
        date: selectedDate,
        context: context,
      );

      if (!mounted) return;
      setState(() {
        _classes = classes ?? [];
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
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
              child: Column(
                children: [
                  UIHelpers.verticalSpace(AppConstants.spacing16),
                  UIHelpers.verticalSpace(AppConstants.spacing32),

                  // Header section with icon and title
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppConstants.spacing12),
                        decoration: BoxDecoration(
                          color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
                        ),
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          color: ColorPalette.darkBlue,
                          size: AppConstants.iconSizeLarge,
                        ),
                      ),
                      UIHelpers.horizontalSpace(AppConstants.spacing16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Attendance',
                              style: AppTextStyles.heading1.copyWith(color: ColorPalette.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            UIHelpers.verticalSpaceSmall,
                            Text(
                              'Generate instant attendance codes for your classes',
                              style: AppTextStyles.bodyMedium.copyWith(
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

            UIHelpers.verticalSpace(AppConstants.spacing32),

            // Scrollable content area
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date selection card
                    Container(
                      decoration: UIHelpers.roundedCardDecoration,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _selectDate(context),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
                          child: Padding(
                            padding: EdgeInsets.all(AppConstants.spacing20),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(AppConstants.spacing12),
                                  decoration: BoxDecoration(
                                    color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    color: ColorPalette.darkBlue,
                                    size: AppConstants.iconSizeMedium,
                                  ),
                                ),
                                UIHelpers.horizontalSpace(AppConstants.spacing16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selected Date',
                                        style: AppTextStyles.caption.copyWith(
                                          color: ColorPalette.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      UIHelpers.verticalSpaceSmall,
                                      Text(
                                        DateFormat('EEEE, MMMM d, yyyy').format(dateState.selectedDate),
                                        style: AppTextStyles.bodyLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: ColorPalette.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: ColorPalette.textSecondary,
                                  size: AppConstants.iconSizeMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    UIHelpers.verticalSpace(AppConstants.spacing24),

                    // Class selection card
                    Container(
                      decoration: UIHelpers.roundedCardDecoration,
                      child: Padding(
                        padding: EdgeInsets.all(AppConstants.spacing20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(AppConstants.spacing12),
                                  decoration: BoxDecoration(
                                    color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                                  ),
                                  child: Icon(
                                    Icons.school_rounded,
                                    color: ColorPalette.darkBlue,
                                    size: AppConstants.iconSizeMedium,
                                  ),
                                ),
                                UIHelpers.horizontalSpace(AppConstants.spacing12),
                                Expanded(
                                  child: Text(
                                    'Select Class Session',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ColorPalette.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            UIHelpers.verticalSpace(AppConstants.spacing16),

                            if (_isLoading)
                              UIHelpers.loadingIndicatorWithText('Loading classes...')
                            else if (_errorMessage != null)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: AppConstants.spacing24),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.error_outline_rounded,
                                        color: Colors.red.shade400,
                                        size: AppConstants.iconSizeLarge,
                                      ),
                                      UIHelpers.verticalSpace(AppConstants.spacing12),
                                      Text(
                                        _errorMessage!,
                                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.red.shade600),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else if (_classes.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: AppConstants.spacing24),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_busy_rounded,
                                        color: ColorPalette.textSecondary,
                                        size: AppConstants.iconSizeLarge,
                                      ),
                                      UIHelpers.verticalSpace(AppConstants.spacing12),
                                      Text(
                                        'No classes scheduled for this date',
                                        style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary),
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
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
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
                              UIHelpers.verticalSpace(AppConstants.spacing16),
                              Container(
                                padding: EdgeInsets.all(AppConstants.spacing16),
                                decoration: BoxDecoration(
                                  color: ColorPalette.darkBlue.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                                  border: Border.all(color: ColorPalette.darkBlue.withValues(alpha: 0.2)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selected Class Details',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: ColorPalette.darkBlue,
                                      ),
                                    ),
                                    UIHelpers.verticalSpace(AppConstants.spacing12),
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
                                    if (_selectedClass['type'] != null) ...[
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
                                            _selectedClass['type'],
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

                    UIHelpers.verticalSpace(AppConstants.spacing24),

                    // Beacon Mode Selection Card
                    if (_selectedClass != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppConstants.spacing20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(AppConstants.spacing12),
                                    decoration: BoxDecoration(
                                      color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                                    ),
                                    child: Icon(
                                      Icons.bluetooth_rounded,
                                      color: ColorPalette.darkBlue,
                                      size: AppConstants.iconSizeMedium,
                                    ),
                                  ),
                                  UIHelpers.horizontalSpace(AppConstants.spacing12),
                                  Text(
                                    'Proximity Verification',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ColorPalette.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              UIHelpers.verticalSpace(AppConstants.spacing16),

                              Text(
                                'Choose how students will verify their proximity:',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: ColorPalette.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              UIHelpers.verticalSpace(AppConstants.spacing12),

                              // Dedicated Beacon Option
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _beaconMode == 'dedicated' ? ColorPalette.darkBlue : Colors.grey.shade300,
                                    width: _beaconMode == 'dedicated' ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                                  color:
                                      _beaconMode == 'dedicated'
                                          ? ColorPalette.darkBlue.withValues(alpha: 0.05)
                                          : Colors.transparent,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => setState(() => _beaconMode = 'dedicated'),
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                                    child: Padding(
                                      padding: EdgeInsets.all(AppConstants.spacing16),
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

                              UIHelpers.verticalSpace(AppConstants.spacing12),

                              // Professor Phone Option
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _beaconMode == 'phone' ? ColorPalette.darkBlue : Colors.grey.shade300,
                                    width: _beaconMode == 'phone' ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                                  color:
                                      _beaconMode == 'phone'
                                          ? ColorPalette.darkBlue.withValues(alpha: 0.05)
                                          : Colors.transparent,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => setState(() => _beaconMode = 'phone'),
                                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                                    child: Padding(
                                      padding: EdgeInsets.all(AppConstants.spacing16),
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
                    UIHelpers.verticalSpace(AppConstants.spacing40),
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
