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
          Icon( icon, size: 18.sp, color: isSelected ? Colors.white : ColorPalette.darkBlue,),
          SizedBox(width: 6.w),
          Flexible( child: Text( label, style: TextStyle( fontSize: 13.sp, color: isSelected ? Colors.white : ColorPalette.darkBlue, fontWeight: FontWeight.w500,), overflow: TextOverflow.ellipsis, maxLines: 1,),),
        ],
      ),
    ),
  );
}

///
/// Helper for Student Info Card
///
Widget buildStudentInfoCard(BuildContext context) {
  return Consumer<UserProvider>(
    builder: (context, userProvider, child) {
      final user = userProvider.currentUser;
      
      // Check if user is a Student and cast if necessary
      final Student? student = user is Student ? user : null;
      
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: ColorPalette.lightestBlue,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student != null 
                        ? 'Hi, ${student.firstName} ${student.lastName}'
                        : 'Hi, Guest User',
                    style: TextStyle(
                      fontSize: 16.sp, 
                      fontWeight: FontWeight.bold, 
                      color: ColorPalette.textPrimary
                    )
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    student != null 
                        ? 'Index: ${student.studentIndex}'
                        : 'Index: -',
                    style: TextStyle(
                      fontSize: 13.sp, 
                      color: ColorPalette.textSecondary
                    )
                  ),
                  Text(
                    student != null 
                        ? 'Study Program: ${student.studyProgramCode ?? "N/A"}'
                        : 'Study Program: -',
                    style: TextStyle(
                      fontSize: 13.sp, 
                      color: ColorPalette.textSecondary
                    )
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Profile page
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const ProfileOverviewScreen()
                        )
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.darkBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 8.h),
                      shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20.r),),
                      textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)
                    ),
                    child: const Text('Profile'),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Container( // Profile picture placeholder
              width: 60.w, height: 60.w,
              decoration: BoxDecoration(
                color: ColorPalette.placeholderGrey, 
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                CupertinoIcons.person_fill, // Changed to person icon
                color: ColorPalette.iconGrey, 
                size: 30.sp
              ),
            ),
          ],
        ),
      );
    },
  );
}

///
/// Helper for Professor Info Card
///
Widget buildProfessorInfoCard(BuildContext context) {
  return Consumer<UserProvider>(
    builder: (context, userProvider, child) {
      final user = userProvider.currentUser;
      final Professor? professor = user is Professor ? user : null;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: ColorPalette.lightestBlue,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    professor != null ? 'Hi, ${professor.name}' : 'Hi, Guest User',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    professor != null ? professor.title : 'Title: -',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: ColorPalette.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileOverviewScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.darkBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                    ),
                    child: const Text('Profile'),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: ColorPalette.placeholderGrey,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                CupertinoIcons.person_fill,
                color: ColorPalette.iconGrey,
                size: 30.sp,
              ),
            ),
          ],
        ),
      );
    },
  );
}

///
/// Helper for Date/Time Chips (Updated Style)
///
Widget buildDateTimeChip(String label, IconData icon, VoidCallback onPressed) {
  return InkWell( // Use InkWell for tap feedback + custom styling
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
            style: TextStyle(fontSize: 14.sp, color: ColorPalette.darkBlue, fontWeight: FontWeight.w500), // DarkBlue Text
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
    color: hasClassStarted 
        ? ColorPalette.lightestBlue.withValues(alpha: 0.9) 
        : ColorPalette.lightestBlue.withValues(alpha: 0.7),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.r),
      side: BorderSide(
        color: hasClassStarted 
            ? ColorPalette.darkBlue.withValues(alpha: 0.3)
            : ColorPalette.placeholderGrey.withValues(alpha: 0.5), 
        width: hasClassStarted ? 1.5.w : 0.5.w
      ),
    ),
    child: Container(
      decoration: hasClassStarted ? BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: ColorPalette.darkBlue.withValues(alpha: 0.1),
            blurRadius: 8.0,
            spreadRadius: 1.0,
            offset: const Offset(0, 2),
          ),
        ],
      ) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 45.w, 
              height: 45.w,
              decoration: BoxDecoration( 
                color: hasClassStarted 
                    ? ColorPalette.darkBlue.withValues(alpha: 0.1)
                    : ColorPalette.placeholderGrey, 
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                CupertinoIcons.rectangle_on_rectangle_angled, 
                color: hasClassStarted 
                    ? ColorPalette.darkBlue
                    : ColorPalette.iconGrey, 
                size: 25.sp
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
                      color: ColorPalette.textPrimary
                    ), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text( 
                    roomName, 
                    style: TextStyle(
                      fontSize: 12.sp, 
                      color: ColorPalette.textSecondary
                    ), 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(width: 10.w),
            
            Container(
              padding: hasClassStarted 
                  ? EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h)
                  : EdgeInsets.zero,
              decoration: hasClassStarted ? BoxDecoration(
                color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ) : null,
              child: Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 13.sp, 
                  color: hasClassStarted 
                      ? ColorPalette.darkBlue
                      : ColorPalette.textSecondary, 
                  fontWeight: hasClassStarted ? FontWeight.w600 : FontWeight.w500
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}