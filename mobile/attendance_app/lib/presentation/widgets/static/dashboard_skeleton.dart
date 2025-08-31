import 'package:flutter/material.dart';
import 'package:attendance_app/presentation/widgets/static/skeleton_loader.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Display 5 shimmering items
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppConstants.spacing12),
          child: Row(
            children: [
              SkeletonLoader(width: AppConstants.iconSizeXLarge, height: AppConstants.iconSizeXLarge),
              UIHelpers.horizontalSpace(AppConstants.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonLoader(width: 150, height: 16),
                    UIHelpers.verticalSpace(AppConstants.spacing4),
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
