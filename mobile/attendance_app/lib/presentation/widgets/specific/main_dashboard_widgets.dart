import 'package:attendance_app/data/models/professor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/presentation/screens/profile_overview.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';
import 'package:logger/logger.dart';

class _MainDashboardWidgets {
  static final Logger _logger = Logger();
}

///
/// Helper for Top Chips
///
Widget buildTopChip(String label, IconData icon, {required bool isSelected, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing12, horizontal: AppConstants.spacing8),
      decoration: BoxDecoration(
        color: isSelected ? ColorPalette.darkBlue : ColorPalette.lightestBlue,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: AppConstants.iconSizeSmall,
            color: isSelected ? ColorPalette.pureWhite : ColorPalette.darkBlue,
          ),
          UIHelpers.horizontalSpace(AppConstants.spacing8),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? ColorPalette.pureWhite : ColorPalette.darkBlue,
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
        margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ColorPalette.darkBlue, ColorPalette.darkBlue.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
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
                width: AppConstants.spacing64,
                height: AppConstants.spacing64,
                decoration: BoxDecoration(
                  color: ColorPalette.pureWhite.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppConstants.spacing32),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(AppConstants.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with avatar and basic info
                  Row(
                    children: [
                      // Profile-style avatar with initials
                      _buildCompactAvatar(student),

                      UIHelpers.horizontalSpace(AppConstants.spacing12),

                      // Basic info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student != null ? '${student.firstName} ${student.lastName}' : 'Guest User',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.pureWhite,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            UIHelpers.verticalSpace(AppConstants.spacing4),
                            Text(
                              student?.studentIndex ?? 'N/A',
                              style: AppTextStyles.caption.copyWith(
                                color: ColorPalette.pureWhite.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Settings button (only one button now)
                      Container(
                        width: AppConstants.iconSizeXLarge,
                        height: AppConstants.iconSizeXLarge,
                        decoration: BoxDecoration(
                          color: ColorPalette.pureWhite.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              fastPush(context, const ProfileOverviewScreen());
                            },
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                            child: Icon(
                              CupertinoIcons.settings,
                              color: ColorPalette.pureWhite,
                              size: AppConstants.iconSizeSmall,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  UIHelpers.verticalSpace(AppConstants.spacing12),

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
                      UIHelpers.horizontalSpace(AppConstants.spacing8),

                      // Status
                      Expanded(
                        child: _buildCompactInfoCard(
                          icon: CupertinoIcons.checkmark_circle_fill,
                          label: 'Status',
                          value: 'Active',
                          valueColor: ColorPalette.successColor,
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
    radius: AppConstants.iconSizeMedium, // Compact size for dashboard
    backgroundColor: ColorPalette.pureWhite.withValues(alpha: 0.2),
    child: Text(
      initials,
      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: ColorPalette.pureWhite),
    ),
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
    padding: EdgeInsets.all(AppConstants.spacing8),
    decoration: BoxDecoration(
      color: ColorPalette.pureWhite.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
      border: Border.all(color: ColorPalette.pureWhite.withValues(alpha: 0.2), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: ColorPalette.pureWhite.withValues(alpha: 0.8), size: AppConstants.iconSizeSmall),
            UIHelpers.horizontalSpace(AppConstants.spacing4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: ColorPalette.pureWhite.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        UIHelpers.verticalSpace(AppConstants.spacing4),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: valueColor ?? ColorPalette.pureWhite,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
        margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ColorPalette.darkBlue, ColorPalette.darkBlue.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
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
                width: AppConstants.spacing64,
                height: AppConstants.spacing64,
                decoration: BoxDecoration(
                  color: ColorPalette.pureWhite.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppConstants.spacing32),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: EdgeInsets.all(AppConstants.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with avatar and basic info
                  Row(
                    children: [
                      // Profile-style avatar with initials
                      _buildCompactProfessorAvatar(professor),

                      UIHelpers.horizontalSpace(AppConstants.spacing12),

                      // Basic info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              professor != null ? professor.name : 'Guest User',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ColorPalette.pureWhite,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            UIHelpers.verticalSpace(AppConstants.spacing4),
                            Text(
                              professor?.title ?? 'Professor',
                              style: AppTextStyles.caption.copyWith(
                                color: ColorPalette.pureWhite.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Settings button
                      Container(
                        width: AppConstants.iconSizeXLarge,
                        height: AppConstants.iconSizeXLarge,
                        decoration: BoxDecoration(
                          color: ColorPalette.pureWhite.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              fastPush(context, const ProfileOverviewScreen());
                            },
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                            child: Icon(
                              CupertinoIcons.settings,
                              color: ColorPalette.pureWhite,
                              size: AppConstants.iconSizeSmall,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  UIHelpers.verticalSpace(AppConstants.spacing12),

                  // Compact info row
                  Row(
                    children: [
                      // Office
                      Expanded(
                        flex: 2,
                        child: _buildCompactInfoCard(
                          icon: CupertinoIcons.building_2_fill,
                          label: 'Office',
                          value: professor?.officeName ?? 'N/A',
                        ),
                      ),
                      UIHelpers.horizontalSpace(AppConstants.spacing8),

                      // Status
                      Expanded(
                        child: _buildCompactInfoCard(
                          icon: CupertinoIcons.checkmark_circle_fill,
                          label: 'Status',
                          value: 'Active',
                          valueColor: ColorPalette.successColor,
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

  final displayName = professor != null ? professor.name : 'Guest User';
  final initials = getInitials(displayName);

  return CircleAvatar(
    radius: AppConstants.iconSizeMedium,
    backgroundColor: ColorPalette.pureWhite.withValues(alpha: 0.2),
    child: Text(
      initials,
      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: ColorPalette.pureWhite),
    ),
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
/// Helper for Class List Items - Redesigned Compact Version
///
Widget buildClassListItem(
  String subjectName,
  String roomName,
  String timeString,
  bool hasClassStarted, {
  String? attendanceStatus,
  bool isReadOnly = false, // Add read-only parameter
}) {
  String formattedTime = timeString;

  if (timeString.isNotEmpty) {
    try {
      final timeParts = timeString.split(':');
      if (timeParts.length >= 2) {
        formattedTime = '${timeParts[0]}:${timeParts[1]}';
      }
    } catch (e) {
      if (kDebugMode) {
        _MainDashboardWidgets._logger.e('Error formatting time: $e');
      }
    }
  }

  // Simple status color logic
  Color _getStatusColor() {
    if (attendanceStatus == null) return ColorPalette.textSecondary;

    switch (attendanceStatus.toLowerCase()) {
      case 'verified':
      case 'confirmed':
      case 'present':
        return ColorPalette.successColor;
      case 'registered':
      case 'pending':
        return ColorPalette.warningColor;
      case 'absent':
      case 'missed':
        return ColorPalette.errorColor;
      default:
        return ColorPalette.textSecondary;
    }
  }

  IconData? _getStatusIcon() {
    if (attendanceStatus == null) return null;

    switch (attendanceStatus.toLowerCase()) {
      case 'verified':
      case 'confirmed':
      case 'present':
        return CupertinoIcons.checkmark_circle;
      case 'registered':
      case 'pending':
        return CupertinoIcons.clock;
      case 'absent':
      case 'missed':
        return CupertinoIcons.xmark_circle;
      default:
        return CupertinoIcons.question_circle;
    }
  }

  return Container(
    margin: EdgeInsets.only(bottom: 6.h), // Reduced spacing
    padding: EdgeInsets.all(10.w), // Reduced padding
    decoration: BoxDecoration(
      color: isReadOnly ? ColorPalette.lightestBlue.withOpacity(0.3) : ColorPalette.pureWhite,
      // Dimmed background for read-only
      borderRadius: BorderRadius.circular(6.r),
      // Smaller radius
      border: Border.all(color: isReadOnly ? Colors.grey.shade300 : Colors.grey.shade200, width: 0.8),
      // Different border for read-only
      boxShadow:
          isReadOnly
              ? []
              : [
                BoxShadow(
                  color: Colors.grey.shade300.withValues(alpha: 0.4), // Lighter shadow
                  blurRadius: 4.0, // Reduced blur
                  offset: const Offset(0, 1), // Less offset
                ),
              ],
    ),
    child: Row(
      children: [
        // Status indicator - smaller
        Container(
          width: 3.w, // Back to original width
          height: 36.h, // Shorter height
          decoration: BoxDecoration(
            color: isReadOnly ? Colors.grey.shade400 : _getStatusColor(), // Grey indicator for read-only
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),

        SizedBox(width: 10.w), // Reduced spacing
        // Content
        Expanded(
          child: Opacity(
            opacity: isReadOnly ? 0.6 : 1.0, // Reduce opacity for read-only classes
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject name and status icon
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subjectName,
                        style: TextStyle(
                          fontSize: 13.sp, // Smaller font
                          fontWeight: FontWeight.w600,
                          color:
                              isReadOnly
                                  ? ColorPalette.textSecondary
                                  : ColorPalette.textPrimary, // Dimmed text for read-only
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_getStatusIcon() != null) ...[
                      Icon(
                        _getStatusIcon()!,
                        size: 14.sp, // Smaller icon
                        color: isReadOnly ? Colors.grey.shade500 : _getStatusColor(), // Grey icon for read-only
                      ),
                    ],
                    // Add a "passed" indicator for read-only classes
                    if (isReadOnly) ...[
                      SizedBox(width: 4.w),
                      Icon(CupertinoIcons.time_solid, size: 12.sp, color: Colors.grey.shade500),
                    ],
                  ],
                ),

                SizedBox(height: 4.h), // Reduced spacing
                // Room and time
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.location,
                      size: 10.sp, // Smaller icon
                      color: ColorPalette.textSecondary,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      roomName,
                      style: TextStyle(
                        fontSize: 11.sp, // Smaller font
                        color: ColorPalette.textSecondary,
                        fontWeight: FontWeight.w400, // Lighter weight
                      ),
                    ),
                    SizedBox(width: 10.w), // Reduced spacing
                    Icon(
                      CupertinoIcons.time,
                      size: 10.sp, // Smaller icon
                      color: ColorPalette.textSecondary,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 11.sp, // Smaller font
                        color: ColorPalette.textSecondary,
                        fontWeight: FontWeight.w400, // Lighter weight
                      ),
                    ),
                    if (isReadOnly) ...[
                      SizedBox(width: 8.w),
                      Text(
                        '(Passed)',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
