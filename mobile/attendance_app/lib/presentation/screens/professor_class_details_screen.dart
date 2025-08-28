import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/data/models/student_attendance.dart';
import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/core/services/standardized_qr_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
      final attendance = await _attendanceRepository.getStudentAttendanceForSession(sessionId);
      setState(() {
        _attendanceList = attendance;
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
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: Text(
          widget.classData['subjectName'] ?? 'Class Details',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: ColorPalette.darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAttendance,
        color: ColorPalette.darkBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildModernClassInfoCard(),
              SizedBox(height: 16.h),
              _buildModernQRButton(),
              SizedBox(height: 16.h),
              _buildModernAttendanceOverview(),
              SizedBox(height: 20.h),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorPalette.darkBlue,
                        ColorPalette.darkBlue.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    CupertinoIcons.book_solid,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    widget.classData['subjectName'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1D29),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _buildModernInfoRow(
              CupertinoIcons.location_solid,
              'Location',
              widget.classData['roomName'] ?? 'N/A',
              Colors.blue,
            ),
            SizedBox(height: 12.h),
            _buildModernInfoRow(
              CupertinoIcons.time_solid,
              'Time',
              '${widget.classData['startTime']} - ${widget.classData['endTime']}',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value, Color accentColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            color: accentColor,
            size: 16.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1D29),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernQRButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorPalette.darkBlue,
            ColorPalette.darkBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.darkBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _generateAndShowQrCode,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    CupertinoIcons.qrcode,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate QR Code',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Start attendance verification process',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    CupertinoIcons.arrow_right,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Expanded(
              child: _buildStatsTile(
                'Present',
                presentCount.toString(),
                CupertinoIcons.person_2_fill,
                Colors.green,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildStatsTile(
                'Attendance',
                '$percentage%',
                CupertinoIcons.chart_pie_fill,
                Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1D29),
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
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
                child: CircularProgressIndicator(
                  color: ColorPalette.darkBlue,
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Loading attendance...',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
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
                child: Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: Colors.red,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
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
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
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
                child: Icon(
                  CupertinoIcons.person_2,
                  color: const Color(0xFF6B7280),
                  size: 48.sp,
                ),
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
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        itemCount: _attendanceList.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: const Color(0xFFF3F4F6),
          indent: 60.w,
        ),
        itemBuilder: (context, index) {
          final attendance = _attendanceList[index];
          return _buildModernStudentTile(attendance);
        },
      ),
    );
  }

  Widget _buildModernStudentTile(StudentAttendance attendance) {
    final statusColor = _getStatusColor(attendance.status ?? 'unknown');
    final statusIcon = _getStatusIcon(attendance.status ?? 'unknown');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor,
                  statusColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              statusIcon,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.studentName ?? 'Unknown Student',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1D29),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  attendance.studentIndex ?? 'No index',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _getStatusText(attendance.status ?? 'unknown'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              if (attendance.studentArrivalTime != null)
                Text(
                  DateFormat('HH:mm').format(attendance.studentArrivalTime!),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'late':
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
        return CupertinoIcons.checkmark_circle_fill;
      case 'late':
        return CupertinoIcons.clock_fill;
      case 'absent':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.person_fill;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      default:
        return 'Unknown';
    }
  }
}
