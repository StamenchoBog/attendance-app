import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/presentation/widgets/static/skeleton_loader.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Display 5 shimmering items
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Row(
            children: [
              const SkeletonLoader(width: 45, height: 45),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(width: 150, height: 16),
                    SizedBox(height: 4.h),
                    const SkeletonLoader(width: 100, height: 12),
                  ],
                ),
              ),
              const SkeletonLoader(width: 50, height: 24),
            ],
          ),
        );
      },
    );
  }
}
