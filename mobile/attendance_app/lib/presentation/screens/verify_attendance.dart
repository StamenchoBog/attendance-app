import 'package:attendance_app/core/services/device_identifier_service.dart';
import 'package:attendance_app/core/utils/error_message_helper.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/presentation/widgets/dialogs/first_time_device_registration_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/presentation/widgets/static/bottom_nav_bar.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';
import 'package:attendance_app/presentation/screens/qr_scanner_screen.dart';
import 'package:provider/provider.dart';
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
      return;
    }

    try {
      // Check if user has a registered device
      final registeredDevice = await _deviceIdentifierService.getRegisteredDevice(user.studentIndex);
      final currentDeviceId = await _deviceIdentifierService.getPlatformSpecificIdentifier();

      if (currentDeviceId == null) {
        _logger.e("Could not get device identifier.");
        return;
      }

      // If no registered device, show first-time registration dialog
      if (registeredDevice['id'] == null) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => FirstTimeDeviceRegistrationDialog(
                  studentIndex: user.studentIndex,
                  onSuccess: () {
                    Navigator.of(context).pop();
                    _proceedToScanner(user.studentIndex, currentDeviceId);
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                  },
                ),
          );
        }
        return;
      }

      // Check if current device matches registered device
      if (registeredDevice['id'] != currentDeviceId) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This device is not registered for attendance. Please use your registered device or request a device change.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // Device is approved, proceed to scanner
      _proceedToScanner(user.studentIndex, currentDeviceId);
    } catch (e) {
      _logger.e("Error checking device registration: $e");

      String errorMessage = 'Error checking device registration. Please try again.';
      bool isRetryable = true;

      if (e is DeviceRegistrationException) {
        errorMessage = ErrorMessageHelper.getDeviceRegistrationErrorMessage(e.errorCode, e.message);
        isRetryable = ErrorMessageHelper.isRetryableError(e.errorCode);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: isRetryable ? 4 : 3),
            action:
                isRetryable ? SnackBarAction(label: 'Retry', textColor: Colors.white, onPressed: _openCamera) : null,
          ),
        );
      }
    }
  }

  void _proceedToScanner(String studentIndex, String deviceId) {
    if (mounted) {
      fastPush(context, QrScannerScreen(studentIndex: studentIndex, deviceId: deviceId));
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(25.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorPalette.lightestBlue,
                        border: Border.all(color: ColorPalette.lightBlue.withValues(alpha: 0.5), width: 2.w),
                      ),
                      child: Icon(CupertinoIcons.qrcode_viewfinder, size: 80.sp, color: ColorPalette.darkBlue),
                    ),
                    SizedBox(height: 30.h),
                    Text(
                      'Verify Your Attendance',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: ColorPalette.textPrimary),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Scan the QR code provided by your professor to instantly mark your presence.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15.sp, color: ColorPalette.textSecondary, height: 1.4),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
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
      bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
