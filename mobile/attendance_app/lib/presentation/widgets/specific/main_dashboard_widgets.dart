import 'package:attendance_app/data/models/professor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/presentation/screens/profile_overview.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';

///
/// Helper for Top Chips
///
Widget buildTopChip(String label, IconData icon, {required bool isSelected, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: isSelected ? ColorPalette.darkBlue : ColorPalette.lightestBlue,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18.sp, color: isSelected ? Colors.white : ColorPalette.darkBlue),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: isSelected ? Colors.white : ColorPalette.darkBlue,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    ),
  );
}

///
/// Compact Student Info Card with modern design
///
Widget buildStudentInfoCard(BuildContext context) {
  return Consumer<UserProvider>(
    builder: (context, userProvider, child) {
      final user = userProvider.currentUser;

      // Check if user is a Student and cast if necessary
      final Student? student = user is Student ? user : null;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ColorPalette.darkBlue, ColorPalette.darkBlue.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: ColorPalette.darkBlue.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 6)),
          ],
        ),
        child: Stack(
          children: [
            // Subtle background pattern
            Positioned(
              top: -15,
              right: -15,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with avatar and basic info
                  Row(
                    children: [
                      // Profile-style avatar with initials
                      _buildCompactAvatar(student),

                      SizedBox(width: 12.w),

                      // Basic info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student != null ? '${student.firstName} ${student.lastName}' : 'Guest User',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              student?.studentIndex ?? 'N/A',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Settings button (only one button now)
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              fastPush(context, const ProfileOverviewScreen());
                            },
                            borderRadius: BorderRadius.circular(10.r),
                            child: Icon(CupertinoIcons.settings, color: Colors.white, size: 18.sp),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Compact info row
                  Row(
                    children: [
                      // Study Program
                      Expanded(
                        flex: 2,
                        child: _buildCompactInfoCard(
                          icon: CupertinoIcons.book_fill,
                          label: 'Program',
                          value: student?.studyProgramCode ?? 'N/A',
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Status
                      Expanded(
                        child: _buildCompactInfoCard(
                          icon: CupertinoIcons.checkmark_circle_fill,
                          label: 'Status',
                          value: 'Active',
                          valueColor: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Helper method to build compact avatar with initials (reusing profile screen style)
Widget _buildCompactAvatar(Student? student) {
  String getInitials(String name) {
    if (name.isEmpty) return '';
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 2 ? 2 : names.length;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0];
      }
    }
    return initials.toUpperCase();
  }

  final displayName = student != null ? '${student.firstName} ${student.lastName}' : 'Guest User';
  final initials = getInitials(displayName);

  return CircleAvatar(
    radius: 24.r, // Compact size for dashboard
    backgroundColor: Colors.white.withValues(alpha: 0.2),
    child: Text(initials, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
  );
}

// Compact helper widget for info cards
Widget _buildCompactInfoCard({
  required IconData icon,
  required String label,
  required String value,
  Color? valueColor,
}) {
  return Container(
    padding: EdgeInsets.all(8.w),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 12.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Text(
          value,
          style: TextStyle(fontSize: 12.sp, color: valueColor ?? Colors.white, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

// Compact helper widget for action buttons
Widget _buildCompactActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 14.sp),
            SizedBox(width: 6.w),
            Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ),
  );
}

///
/// Compact Professor Info Card with modern design (standardized)
///
Widget buildProfessorInfoCard(BuildContext context) {
  return Consumer<UserProvider>(
    builder: (context, userProvider, child) {
      final user = userProvider.currentUser;

      // Check if user is a Professor and cast if necessary
      final Professor? professor = user is Professor ? user : null;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ColorPalette.darkBlue, ColorPalette.darkBlue.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: ColorPalette.darkBlue.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 6)),
          ],
        ),
        child: Stack(
          children: [
            // Subtle background pattern
            Positioned(
              top: -15,
              right: -15,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with avatar and basic info
                  Row(
                    children: [
                      // Profile-style avatar with initials
                      _buildCompactProfessorAvatar(professor),

                      SizedBox(width: 12.w),

                      // Basic info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              professor?.name ?? 'Guest User',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              professor?.id ?? 'N/A',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Settings button
                      Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              fastPush(context, const ProfileOverviewScreen());
                            },
                            borderRadius: BorderRadius.circular(10.r),
                            child: Icon(CupertinoIcons.settings, color: Colors.white, size: 18.sp),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Compact info row
                  Row(
                    children: [
                      // Academic Title
                      Expanded(
                        flex: 2,
                        child: _buildCompactInfoCard(
                          icon: CupertinoIcons.person_badge_plus_fill,
                          label: 'Title',
                          value: professor?.title ?? 'N/A',
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // Status
                      Expanded(
                        child: _buildCompactInfoCard(
                          icon: CupertinoIcons.checkmark_circle_fill,
                          label: 'Status',
                          value: 'Active',
                          valueColor: Colors.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Helper method to build compact professor avatar with initials
Widget _buildCompactProfessorAvatar(Professor? professor) {
  String getInitials(String name) {
    if (name.isEmpty) return '';
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 2 ? 2 : names.length;
    for (var i = 0; i < numWords; i++) {
      if (names[i].isNotEmpty) {
        initials += names[i][0];
      }
    }
    return initials.toUpperCase();
  }

  final displayName = professor?.name ?? 'Guest User';
  final initials = getInitials(displayName);

  return CircleAvatar(
    radius: 24.r, // Compact size for dashboard
    backgroundColor: Colors.white.withValues(alpha: 0.2),
    child: Text(initials, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
  );
}

///
/// Helper for Date/Time Chips (Updated Style)
///
Widget buildDateTimeChip(String label, IconData icon, VoidCallback onPressed) {
  return InkWell(
    // Use InkWell for tap feedback + custom styling
    onTap: onPressed,
    borderRadius: BorderRadius.circular(10.r),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: ColorPalette.lightestBlue, // Use LightestBlue for default background
        borderRadius: BorderRadius.circular(10.r),
        // Optional: Subtle border instead of shadow
        border: Border.all(color: ColorPalette.placeholderGrey.withValues(alpha: 0.8), width: 1.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Let chip size naturally
        children: [
          Icon(icon, color: ColorPalette.darkBlue, size: 16.sp), // DarkBlue icon
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: ColorPalette.darkBlue, fontWeight: FontWeight.w500),
            // DarkBlue Text
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}

///
/// Helper for Class List Items (Updated Style)
///
Widget buildClassListItem(String subjectName, String roomName, String timeString, bool hasClassStarted) {
  String formattedTime = timeString;

  if (timeString.isNotEmpty) {
    try {
      final timeParts = timeString.split(':');
      if (timeParts.length >= 2) {
        formattedTime = '${timeParts[0]}:${timeParts[1]}';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting time: $e');
      }
    }
  }
  return Card(
    margin: EdgeInsets.only(bottom: 10.h),
    elevation: hasClassStarted ? 8.0 : 0,
    color:
        hasClassStarted
            ? ColorPalette.lightestBlue.withValues(alpha: 0.9)
            : ColorPalette.lightestBlue.withValues(alpha: 0.7),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.r),
      side: BorderSide(
        color:
            hasClassStarted
                ? ColorPalette.darkBlue.withValues(alpha: 0.3)
                : ColorPalette.placeholderGrey.withValues(alpha: 0.5),
        width: hasClassStarted ? 1.5.w : 0.5.w,
      ),
    ),
    child: Container(
      decoration:
          hasClassStarted
              ? BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              )
              : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                color: hasClassStarted ? ColorPalette.darkBlue.withValues(alpha: 0.1) : ColorPalette.placeholderGrey,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                CupertinoIcons.rectangle_on_rectangle_angled,
                color: hasClassStarted ? ColorPalette.darkBlue : ColorPalette.iconGrey,
                size: 25.sp,
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subjectName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: hasClassStarted ? FontWeight.w700 : FontWeight.w600,
                      color: ColorPalette.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    roomName,
                    style: TextStyle(fontSize: 12.sp, color: ColorPalette.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(width: 10.w),

            Container(
              padding: hasClassStarted ? EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h) : EdgeInsets.zero,
              decoration:
                  hasClassStarted
                      ? BoxDecoration(
                        color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      )
                      : null,
              child: Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: hasClassStarted ? ColorPalette.darkBlue : ColorPalette.textSecondary,
                  fontWeight: hasClassStarted ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
