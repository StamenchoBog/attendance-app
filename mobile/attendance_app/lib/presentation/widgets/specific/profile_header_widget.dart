// lib/presentation/widgets/profile_header_widget.dart
import 'package:attendance_app/data/models/professor.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String? id;
  final String? name;
  final String? imageUrl; // TODO: Optional image URL

  const ProfileHeaderWidget({
    super.key,
    this.id,      // Placeholder default
    this.name,
    this.imageUrl,
  });

@override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        
        // Use provider data if available, otherwise fall back to parameters
        final displayName = user != null 
            ? user.name
            : name ?? 'Guest User';
            
        final displayId = user != null
            ? (user is Student 
                ? (user).studentIndex
                : (user is Professor 
                    ? (user).title
                    : 'User'))
            : id ?? '';
        
        return Center(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              CircleAvatar(
                radius: 55.r,
                backgroundColor: ColorPalette.lightestBlue,
                child: imageUrl == null || imageUrl!.isEmpty
                    ? Icon(
                        CupertinoIcons.person_fill,
                        size: 60.sp,
                        color: ColorPalette.darkBlue.withValues(alpha: 0.8),
                      )
                    : ClipOval(
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          width: 110.r,
                          height: 110.r,
                        ),
                      ),
              ),
              SizedBox(height: 15.h),
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.textPrimary,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                displayId,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorPalette.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
