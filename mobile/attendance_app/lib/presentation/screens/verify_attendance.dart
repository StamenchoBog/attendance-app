import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:attendance_app/core/theme/color_palette.dart';

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

  int _selectedIndex = 2;

  // --- Methods ---

  // Bottom Navigation tap
  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      handleBottomNavigation(context, index);
    }
  }

  // Placeholder for opening the camera/scanner
  void _openCamera() {
    _logger.i("Open Camera button tapped");
    // TODO: Implement QR Code scanning logic using a package like mobile_scanner or qr_code_scanner
    // Navigator.push(context, MaterialPageRoute(builder: (_) => QrScannerScreen()));
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

              // --- Top Bar (Logo + Search) - Copied ---
              AppTopBar(
                searchHintText: 'Search',
                onSearchChanged: (value) {
                  // TODO: Implement search
                },
              ),

              const Spacer(flex: 2),

              // --- Main Content ---
              Image.asset(
                'assets/icons/qr_code_scan.png',
                height: 150.w,
                width: 150.w,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150.w, width: 150.w, color: ColorPalette.placeholderGrey,
                  child: Center(child: Icon(CupertinoIcons.qrcode, size: 80.sp, color: ColorPalette.iconGrey)),
                ),
              ),

              SizedBox(height: 30.h),

              Text(
                'Verify attendance immediately',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.textPrimary,
                ),
              ),

              SizedBox(height: 10.h),

              Text(
                'Verify your attendance immediately from the QR code provided by the professor',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorPalette.textSecondary,
                  height: 1.3, // Line height
                ),
              ),

              SizedBox(height: 35.h),

              // Open Camera Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.darkBlue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _openCamera,
                child: const Text('Open Camera'),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
