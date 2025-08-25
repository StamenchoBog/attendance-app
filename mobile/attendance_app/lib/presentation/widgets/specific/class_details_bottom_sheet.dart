import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ClassDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> classData;
  final VoidCallback onVerifyAttendance;

  const ClassDetailsBottomSheet({
    super.key,
    required this.classData,
    required this.onVerifyAttendance,
  });

  @override
  Widget build(BuildContext context) {
    String formatTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return '';
      try {
        final parts = timeStr.split(':');
        return '${parts[0]}:${parts[1]}';
      } catch (e) {
        return timeStr; // Return original string if format is unexpected
      }
    }

    final formattedStartTime = formatTime(classData['classStartTime'] as String?);
    final formattedEndTime = formatTime(classData['classEndTime'] as String?);
    final timeValue = '$formattedStartTime - $formattedEndTime';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Title and Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  classData['subjectName'] ?? 'Class Details',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: ColorPalette.textPrimary),
                ),
              ),
              SizedBox(width: 12.w),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(CupertinoIcons.xmark_circle_fill),
                onPressed: () => Navigator.of(context).pop(),
                color: Colors.grey,
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Details Section
          _buildDetailRow(CupertinoIcons.person_alt, 'Professor', classData['professorName'] ?? 'N/A'),
          _buildDetailRow(CupertinoIcons.book, 'Type', classData['classType'] ?? 'N/A'),
          _buildDetailRow(CupertinoIcons.location, 'Room', classData['classRoomName'] ?? 'N/A'),
          _buildDetailRow(CupertinoIcons.clock, 'Time', timeValue),

          SizedBox(height: 24.h),

          // Action Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorPalette.darkBlue,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            onPressed: onVerifyAttendance,
            child: const Text('Verify Attendance'),
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, color: ColorPalette.iconGrey, size: 20.sp),
          SizedBox(width: 15.w),
          Text(
            '$label:',
            style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
