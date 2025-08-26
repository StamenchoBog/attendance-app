import 'package:attendance_app/core/services/device_identifier_service.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/presentation/screens/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:provider/provider.dart';

// Widgets
import 'package:attendance_app/presentation/widgets/static/app_top_bar.dart';
import 'package:attendance_app/presentation/widgets/static/bottom_nav_bar.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';
import 'package:logger/logger.dart';

class VerifyAttendanceScreen extends StatefulWidget {
  const VerifyAttendanceScreen({super.key});

  @override
  State<VerifyAttendanceScreen> createState() => _VerifyAttendanceScreenState();
}

class _VerifyAttendanceScreenState extends State<VerifyAttendanceScreen> {
  static final Logger _logger = Logger();
  final DeviceIdentifierService _deviceIdentifierService = DeviceIdentifierService();
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      handleBottomNavigation(context, index);
    }
  }

  Future<void> _openCamera() async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser as Student?;
    if (user == null) {
      _logger.e("No student is currently logged in.");
      // Optionally show a snackbar
      return;
    }

    final deviceId = await _deviceIdentifierService.getOrGenerateAppSpecificUuid();
    if (deviceId == null) {
      _logger.e("Could not get or generate a device ID.");
      // Optionally show a snackbar
      return;
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QrScannerScreen(
            studentIndex: user.studentIndex,
            deviceId: deviceId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 15.h),
              AppTopBar(
                searchHintText: 'Search',
                onSearchChanged: (value) {
                  // TODO: Implement search if needed on this screen
                },
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(25.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorPalette.lightestBlue,
                        border: Border.all(
                          color: ColorPalette.lightBlue.withOpacity(0.5),
                          width: 2.w,
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.qrcode_viewfinder,
                        size: 80.sp,
                        color: ColorPalette.darkBlue,
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      'Verify Your Attendance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Scan the QR code provided by your professor to instantly mark your presence.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: ColorPalette.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 30.h),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.darkBlue,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 55.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    textStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _openCamera,
                  icon: const Icon(CupertinoIcons.camera),
                  label: const Text('Open Camera to Scan'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}