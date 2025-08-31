import 'package:attendance_app/data/repositories/student_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/presentation/widgets/specific/profile_header_widget.dart';
import 'package:attendance_app/presentation/widgets/static/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/data/models/student.dart';

// Screens
import 'package:attendance_app/presentation/screens/sign_in_screen.dart';

// Widgets
import 'package:attendance_app/presentation/widgets/static/bottom_nav_bar.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';

class ProfileOverviewScreen extends StatefulWidget {
  const ProfileOverviewScreen({super.key});

  @override
  State<ProfileOverviewScreen> createState() => _ProfileOverviewScreenState();
}

class _ProfileOverviewScreenState extends State<ProfileOverviewScreen> {
  int _selectedIndex = 3;
  final StudentRepository _studentRepository = locator<StudentRepository>();
  late Future<Map<String, dynamic>> _attendanceSummaryFuture;

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  void _loadSummaryData() {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user is Student) {
      _attendanceSummaryFuture = _studentRepository
          .getAttendanceSummary(user.studentIndex, 'current') // Need to provide semester parameter
          .then((value) => value ?? <String, dynamic>{});
    } else {
      _attendanceSummaryFuture = Future.value(<String, dynamic>{});
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      handleBottomNavigation(context, index);
    }
  }

  void _logOut() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius16)),
          title: Text(
            "Log out",
            textAlign: TextAlign.center,
            style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold, color: ColorPalette.textPrimary),
          ),
          content: Text(
            "Are you sure you want to log out? You'll need to login again to use the app.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.secondaryTextColor, height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: EdgeInsets.only(
            left: AppConstants.spacing16,
            right: AppConstants.spacing16,
            bottom: AppConstants.spacing16,
            top: AppConstants.spacing8,
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorPalette.darkBlue,
                      side: BorderSide(color: ColorPalette.darkBlue, width: 1.5.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius12)),
                      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing12),
                    ),
                    child: Text("Cancel", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
                UIHelpers.horizontalSpace(AppConstants.spacing12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.darkBlue,
                      foregroundColor: ColorPalette.pureWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius12)),
                      padding: EdgeInsets.symmetric(vertical: AppConstants.spacing12),
                      elevation: 1,
                    ),
                    child: Text("Log out", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Provider.of<UserProvider>(context, listen: false).logout();
                      if (mounted) {
                        fastPushAndRemoveUntil(context, const SignInScreen());
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: AppTextStyles.heading3.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
        child: ListView(
          children: [
            const ProfileHeaderWidget(),
            UIHelpers.verticalSpace(AppConstants.spacing24),
            if (user is Student) _buildAttendanceSummary(),
            UIHelpers.verticalSpace(AppConstants.spacing24),
            _buildSettingsAndActions(),
            UIHelpers.verticalSpace(AppConstants.spacing40),
            Padding(
              padding: EdgeInsets.only(bottom: AppConstants.spacing20, top: AppConstants.spacing16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.darkBlue,
                  foregroundColor: ColorPalette.pureWhite,
                  minimumSize: Size(double.infinity, AppConstants.buttonHeight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius12)),
                  textStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                onPressed: _logOut,
                child: const Text("Log out"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }

  Widget _buildAttendanceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ATTENDANCE SUMMARY',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorPalette.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        UIHelpers.verticalSpace(AppConstants.spacing12),
        FutureBuilder<Map<String, dynamic>>(
          future: _attendanceSummaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildSummarySkeleton();
            } else if (snapshot.hasError) {
              return const Center(child: Text('Could not load summary.'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final summary = snapshot.data!;
              return Row(
                children: [
                  Expanded(child: _buildSummaryCard('Overall Attendance', '${summary['overallPercentage']}%')),
                  UIHelpers.horizontalSpace(AppConstants.spacing16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Classes Attended',
                      '${summary['attendedClasses']}/${summary['totalClasses']}',
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing16, vertical: AppConstants.spacing12),
      decoration: BoxDecoration(
        color: ColorPalette.lightestBlue,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(color: ColorPalette.textSecondary, fontWeight: FontWeight.w500),
          ),
          UIHelpers.verticalSpace(AppConstants.spacing8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: ColorPalette.darkBlue, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySkeleton() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonLoader(width: 120, height: 14),
              UIHelpers.verticalSpace(AppConstants.spacing8),
              const SkeletonLoader(width: 60, height: 24),
            ],
          ),
        ),
        UIHelpers.horizontalSpace(AppConstants.spacing16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonLoader(width: 120, height: 14),
              UIHelpers.verticalSpace(AppConstants.spacing8),
              const SkeletonLoader(width: 80, height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsAndActions() {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SETTINGS & ACTIONS',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorPalette.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        UIHelpers.verticalSpace(AppConstants.spacing12),
        _buildSettingsItem('Languages', onTap: () => navigateToSetting(context, 'languages')),
        if (user is Student) _buildSettingsItem('Devices', onTap: () => navigateToSetting(context, 'devices')),
        _buildSettingsItem(
          'Report a problem',
          onTap: () => navigateToSetting(context, 'report_a_problem'),
          showDivider: false,
        ),
      ],
    );
  }

  Widget _buildSettingsItem(String title, {required VoidCallback onTap, bool showDivider = true}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppConstants.spacing12),
            child: Row(
              children: [
                Expanded(child: Text(title, style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textPrimary))),
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: AppConstants.iconSizeMedium,
                  color: ColorPalette.iconGrey.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
          if (showDivider) UIHelpers.divider,
        ],
      ),
    );
  }
}
