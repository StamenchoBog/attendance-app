import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClassDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> classData;
  final VoidCallback onVerifyAttendance;
  final bool hasPassed;

  const ClassDetailsBottomSheet({
    super.key,
    required this.classData,
    required this.onVerifyAttendance,
    this.hasPassed = false,
  });

  @override
  Widget build(BuildContext context) {
    String formatTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return '';
      try {
        final parts = timeStr.split(':');
        return '${parts[0]}:${parts[1]}';
      } catch (e) {
        return timeStr;
      }
    }

    final formattedStartTime = formatTime(classData['classStartTime'] as String?);
    final formattedEndTime = formatTime(classData['classEndTime'] as String?);
    final timeValue = '$formattedStartTime - $formattedEndTime';

    final attendanceStatus = classData['attendanceStatus'] as String?;
    final isVerified =
        attendanceStatus != null && ['verified', 'confirmed', 'present'].contains(attendanceStatus.toLowerCase());

    return Container(
      height: MediaQuery.of(context).size.height * 0.40, // Fixed 35% height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8.0, offset: Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 30.w,
            height: 3.h,
            margin: EdgeInsets.only(top: 8.h, bottom: 12.h),
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)),
          ),

          // Content - Use Expanded to fill available space
          Expanded(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Compact header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            classData['subjectName'] ?? 'Class Details',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: ColorPalette.textPrimary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(CupertinoIcons.xmark, color: ColorPalette.textSecondary, size: 20.sp),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Compact info grid
                    _buildCompactInfoGrid(
                      classData['professorName'] ?? 'N/A',
                      timeValue.isNotEmpty ? timeValue : 'N/A',
                      classData['classRoomName'] ?? 'N/A',
                      attendanceStatus,
                    ),

                    SizedBox(height: 16.h),

                    // Action button or status - conditionally rendered based on content
                    _buildActionSection(isVerified, attendanceStatus),

                    // Bottom padding to ensure content doesn't touch the bottom
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoGrid(String professor, String time, String room, String? status) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoItem(CupertinoIcons.person, 'Professor', professor)),
              SizedBox(width: 12.w),
              Expanded(child: _buildInfoItem(CupertinoIcons.location, 'Room', room)),
            ],
          ),

          SizedBox(height: 8.h),

          // Second row - Time (full width)
          _buildInfoItem(CupertinoIcons.time, 'Time', time),

          // Third row - Status (if available)
          if (status != null) ...[SizedBox(height: 8.h), _buildStatusItem(status)],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: ColorPalette.textSecondary), // Increased from 13.sp
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: ColorPalette.textSecondary,
                fontWeight: FontWeight.w500,
              ), // Increased from 11.sp
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
          // Increased from 13.sp
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusItem(String status) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status.toLowerCase()) {
      case 'verified':
      case 'present':
        statusColor = ColorPalette.successColor;
        statusIcon = CupertinoIcons.checkmark_circle;
        statusText = 'Verified';
      case 'pending':
      case 'registered':
        statusColor = ColorPalette.warningColor;
        statusIcon = CupertinoIcons.clock;
        statusText = 'Pending';
      case 'absent':
        statusColor = ColorPalette.errorColor;
        statusIcon = CupertinoIcons.xmark_circle;
        statusText = 'Absent';
      default:
        statusColor = ColorPalette.textSecondary;
        statusIcon = CupertinoIcons.question_circle;
        statusText = 'Not verified';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(statusIcon, size: 14.sp, color: statusColor), // Increased from 13.sp
            SizedBox(width: 4.w),
            Text(
              'Status',
              style: TextStyle(
                fontSize: 12.sp,
                color: ColorPalette.textSecondary,
                fontWeight: FontWeight.w500,
              ), // Increased from 11.sp
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(statusText, style: TextStyle(fontSize: 14.sp, color: statusColor, fontWeight: FontWeight.w600)),
        // Increased from 13.sp
      ],
    );
  }

  Widget _buildActionSection(bool isVerified, String? attendanceStatus) {
    if (!isVerified && attendanceStatus?.toLowerCase() != 'absent' && !hasPassed) {
      return SizedBox(
        width: double.infinity,
        height: 40.h, // Smaller button
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPalette.darkBlue,
            foregroundColor: ColorPalette.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          onPressed: onVerifyAttendance,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.qrcode, size: 18.sp),
              SizedBox(width: 6.w),
              Text('Verify Attendance', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    } else if (isVerified) {
      return Container(
        width: double.infinity,
        height: 40.h,
        decoration: BoxDecoration(
          color: ColorPalette.successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: ColorPalette.successColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.checkmark_circle, color: ColorPalette.successColor, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              'Marked as Present',
              style: TextStyle(fontSize: 15.sp, color: ColorPalette.successColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    } else if (attendanceStatus?.toLowerCase() == 'absent') {
      return Container(
        width: double.infinity,
        height: 40.h,
        decoration: BoxDecoration(
          color: ColorPalette.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: ColorPalette.errorColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.xmark_circle, color: ColorPalette.errorColor, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              'Marked as Absent',
              style: TextStyle(fontSize: 15.sp, color: ColorPalette.errorColor, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink(); // Return an empty widget if no action is needed
  }
}
