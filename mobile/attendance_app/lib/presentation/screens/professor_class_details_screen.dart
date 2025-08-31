import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/data/models/student_attendance.dart';
import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/core/services/standardized_qr_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';

class ProfessorClassDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> classData;

  const ProfessorClassDetailsScreen({super.key, required this.classData});

  @override
  State<ProfessorClassDetailsScreen> createState() => _ProfessorClassDetailsScreenState();
}

class _ProfessorClassDetailsScreenState extends State<ProfessorClassDetailsScreen> {
  final AttendanceRepository _attendanceRepository = locator<AttendanceRepository>();
  final Logger _logger = Logger();
  List<StudentAttendance> _attendanceList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final sessionId = int.parse(widget.classData['professorClassSessionId']);
      final attendance = await _attendanceRepository.getStudentAttendancesByLectureId(sessionId);
      setState(() {
        _attendanceList = attendance ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load attendance data.";
        _isLoading = false;
      });
      _logger.e(e);
    }
  }

  Future<void> _generateAndShowQrCode() async {
    // Use the standardized QR service that includes beacon configuration
    await StandardizedQRService.generateStandardizedQR(
      context: context,
      classData: widget.classData,
      showBeaconModeSelector: true, // Show beacon mode selection dialog
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.screenBackgroundLight,
      appBar: AppBar(
        title: Text(
          widget.classData['subjectName'] ?? 'Class Details',
          style: AppTextStyles.heading3.copyWith(color: ColorPalette.pureWhite),
        ),
        backgroundColor: ColorPalette.darkBlue,
        foregroundColor: ColorPalette.pureWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAttendance,
        color: ColorPalette.darkBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppConstants.paddingScreenDefault,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildModernClassInfoCard(),
              UIHelpers.verticalSpaceMedium,
              _buildModernQRButton(),
              UIHelpers.verticalSpaceMedium,
              _buildModernAttendanceOverview(),
              UIHelpers.verticalSpaceLarge,
              _buildModernAttendanceSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernClassInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: ColorPalette.pureWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.classData['subjectName'] ?? 'N/A',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: ColorPalette.textDark,
                letterSpacing: -0.3,
                height: 1.3, // Better line height for wrapped text
              ),
              maxLines: 3, // Allow up to 3 lines for longer course names
              overflow: TextOverflow.ellipsis, // Ellipsis only after 3 lines
            ),
            SizedBox(height: 16.h),

            // Compact info layout - reorganized
            Column(
              children: [
                // First row - Location (full width)
                _buildCompactInfoItem(CupertinoIcons.location, widget.classData['roomName'] ?? 'N/A'),
                SizedBox(height: 12.h),
                // Second row - Time (full width)
                _buildCompactInfoItem(
                  CupertinoIcons.time,
                  '${widget.classData['startTime']} - ${widget.classData['endTime']}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInfoItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: ColorPalette.textSecondary, size: 16.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp, color: ColorPalette.textDark, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildModernQRButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [ColorPalette.darkBlue, ColorPalette.darkBlue.withValues(alpha: 0.8)]),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _generateAndShowQrCode,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              children: [
                Icon(CupertinoIcons.qrcode, color: Colors.white, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Generate QR Code',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                Icon(CupertinoIcons.arrow_right, color: Colors.white, size: 16.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernAttendanceOverview() {
    final presentCount = _attendanceList.length;
    final totalStudents = 30; // This could be dynamic based on enrolled students
    final percentage = totalStudents > 0 ? (presentCount / totalStudents * 100).round() : 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Expanded(child: _buildCompactStatsTile('Present', presentCount.toString(), Colors.green)),
            Container(width: 1, height: 40.h, color: Colors.grey.shade200),
            Expanded(child: _buildCompactStatsTile('Rate', '$percentage%', Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatsTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: color)),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: ColorPalette.textSecondary)),
      ],
    );
  }

  Widget _buildModernAttendanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Student Attendance',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1D29),
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 16.h),
        _buildModernAttendanceList(),
      ],
    );
  }

  Widget _buildModernAttendanceList() {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(40.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: CircularProgressIndicator(color: ColorPalette.darkBlue, strokeWidth: 3),
              ),
              SizedBox(height: 20.h),
              Text(
                'Loading attendance...',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.red, size: 32.sp),
              ),
              SizedBox(height: 20.h),
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ColorPalette.darkBlue, ColorPalette.darkBlue.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: ElevatedButton(
                  onPressed: _loadAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('Retry', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_attendanceList.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7280).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(CupertinoIcons.person_2, color: const Color(0xFF6B7280), size: 48.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                'No students yet',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1D29),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Students will appear here after scanning the QR code',
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        itemCount: _attendanceList.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: const Color(0xFFF3F4F6), indent: 60.w),
        itemBuilder: (context, index) {
          final attendance = _attendanceList[index];
          return _buildModernStudentTile(attendance);
        },
      ),
    );
  }

  Widget _buildModernStudentTile(StudentAttendance attendance) {
    // Fix the status and index handling
    final status = attendance.status ?? 'present';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    // Proper handling of student data - fix the null checking
    final studentIndex = attendance.studentIndex?.isNotEmpty == true
        ? attendance.studentIndex!
        : 'N/A';

    final studentName = attendance.studentName?.isNotEmpty == true
        ? attendance.studentName!
        : 'Unknown Student';

    // Safe avatar text generation
    String avatarText;
    if (studentIndex != 'N/A' && studentIndex.length > 4) {
      avatarText = studentIndex.substring(studentIndex.length - 4); // Last 4 chars
    } else if (studentIndex != 'N/A') {
      avatarText = studentIndex; // Use whole index if short
    } else {
      // Fallback to initials from name
      avatarText = studentName.split(' ').map((word) => word.isNotEmpty ? word[0] : '').take(2).join('').toUpperCase();
      if (avatarText.isEmpty) avatarText = 'ST'; // Final fallback
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Row(
        children: [
          // Student avatar with index - safe substring for display
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                avatarText,
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: statusColor),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Student info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: ColorPalette.textDark),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(
                      studentIndex,
                      style: TextStyle(fontSize: 12.sp, color: ColorPalette.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    // Add indicator if data is missing
                    if (studentIndex == 'N/A' || studentName == 'Unknown Student') ...[
                      SizedBox(width: 4.w),
                      Icon(
                        CupertinoIcons.info_circle,
                        size: 12.sp,
                        color: ColorPalette.warningColor,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Status indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 12.sp),
                SizedBox(width: 4.w),
                Text(
                  _getStatusText(status),
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
      case 'verified':
      case 'confirmed':
        return Colors.green;
      case 'pending':
      case 'registered':
        return Colors.orange;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
      case 'verified':
      case 'confirmed':
        return CupertinoIcons.checkmark_circle_fill;
      case 'pending':
      case 'registered':
        return CupertinoIcons.clock_fill;
      case 'absent':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.question_circle_fill;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'present':
      case 'verified':
      case 'confirmed':
        return 'Present';
      case 'pending':
      case 'registered':
        return 'Pending';
      case 'absent':
        return 'Absent';
      default:
        return 'Unknown';
    }
  }
}
