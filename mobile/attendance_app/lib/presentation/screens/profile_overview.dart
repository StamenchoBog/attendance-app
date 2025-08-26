import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/presentation/widgets/specific/profile_header_widget.dart';
import 'package:attendance_app/presentation/widgets/static/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/data/models/professor.dart';
import 'package:attendance_app/data/models/student.dart';

// Screens
import 'package:attendance_app/presentation/screens/sign_in_screen.dart';

// Widgets
import 'package:attendance_app/presentation/widgets/static/bottom_nav_bar.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';
import 'package:logger/logger.dart';

class ProfileOverviewScreen extends StatefulWidget {
  const ProfileOverviewScreen({super.key});

  @override
  State<ProfileOverviewScreen> createState() => _ProfileOverviewScreenState();
}

class _ProfileOverviewScreenState extends State<ProfileOverviewScreen> {
  int _selectedIndex = 3;
  final Logger _logger = Logger();
  final AttendanceRepository _attendanceRepository = locator<AttendanceRepository>();
  late Future<Map<String, dynamic>> _attendanceSummaryFuture;

  @override
  void initState() {
    super.initState();
    _loadSummaryData();
  }

  void _loadSummaryData() {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user is Student) {
      _attendanceSummaryFuture = _attendanceRepository.getAttendanceSummary(user.studentIndex);
    } else {
      _attendanceSummaryFuture = Future.value({});
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text("Log out", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp, color: ColorPalette.textPrimary)),
          content: Text("Are you sure you want to log out? You'll need to login again to use the app.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary, height: 1.4)),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: EdgeInsets.only(left: 15.w, right: 15.w, bottom: 15.h, top: 5.h),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: ColorPalette.darkBlue, side: BorderSide(color: ColorPalette.darkBlue, width: 1.5.w), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), padding: EdgeInsets.symmetric(vertical: 12.h)),
                    child: Text("Cancel", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: ColorPalette.darkBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), padding: EdgeInsets.symmetric(vertical: 12.h), elevation: 1),
                    child: Text("Log out", style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Provider.of<UserProvider>(context, listen: false).logout();
                      if (mounted) {
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const SignInScreen()),
                          (Route<dynamic> route) => false,
                        );
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
        title: Text("Profile", style: TextStyle(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600, fontSize: 18.sp)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: ListView(
          children: [
            const ProfileHeaderWidget(),
            SizedBox(height: 25.h),
            if (user is Student) _buildAttendanceSummary(),
            SizedBox(height: 25.h),
            _buildSettingsAndActions(),
            SizedBox(height: 40.h), // Add some spacing before the button
            Padding(
              padding: EdgeInsets.only(bottom: 20.h, top: 15.h),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.darkBlue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                onPressed: _logOut,
                child: const Text("Log out"),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ATTENDANCE SUMMARY', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: ColorPalette.textSecondary, letterSpacing: 0.8)),
        SizedBox(height: 10.h),
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
                  SizedBox(width: 15.w),
                  Expanded(child: _buildSummaryCard('Classes Attended', '${summary['attendedClasses']}/${summary['totalClasses']}')),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: ColorPalette.lightestBlue,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 13.sp, color: ColorPalette.textSecondary, fontWeight: FontWeight.w500)),
          SizedBox(height: 6.h),
          Text(value, style: TextStyle(fontSize: 22.sp, color: ColorPalette.darkBlue, fontWeight: FontWeight.bold)),
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
              SizedBox(height: 6.h),
              const SkeletonLoader(width: 60, height: 24),
            ],
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonLoader(width: 120, height: 14),
              SizedBox(height: 6.h),
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
        Text('SETTINGS & ACTIONS', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: ColorPalette.textSecondary, letterSpacing: 0.8)),
        SizedBox(height: 10.h),
        _buildSettingsItem('Languages', onTap: () => navigateToSetting(context, 'languages')),
        if (user is Student)
          _buildSettingsItem('Devices', onTap: () => navigateToSetting(context, 'devices')),
        _buildSettingsItem('Report a problem', onTap: () => navigateToSetting(context, 'report_a_problem'), showDivider: false),
      ],
    );
  }

  Widget _buildSettingsItem(String title, {required VoidCallback onTap, bool showDivider = true}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                Expanded(child: Text(title, style: TextStyle(fontSize: 15.sp, color: ColorPalette.textPrimary))),
                Icon(CupertinoIcons.chevron_forward, size: 20.sp, color: ColorPalette.iconGrey.withOpacity(0.8)),
              ],
            ),
          ),
          if (showDivider) Divider(height: 1.h, thickness: 1.h, color: Colors.grey[200]),
        ],
      ),
    );
  }
}
