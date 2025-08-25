import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
// Widgets
import 'package:attendance_app/presentation/widgets/specific/profile_header_widget.dart';
import 'package:attendance_app/core/services/device_identifier_service.dart';

class DevicesOverviewScreen extends StatefulWidget {
  const DevicesOverviewScreen({super.key});

  @override
  State<DevicesOverviewScreen> createState() => _DevicesOverviewScreenState();
}

class _DevicesOverviewScreenState extends State<DevicesOverviewScreen> {
  final DeviceIdentifierService _deviceIdentifierService = DeviceIdentifierService();

  String? _deviceName;
  String? _deviceOS;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceName = await _deviceIdentifierService.getDeviceName();
      final deviceOS = await _deviceIdentifierService.getOsVersion();
      
      setState(() {
        _deviceName = deviceName ?? 'Unknown';
        _deviceOS = deviceOS ?? 'Unknown';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _deviceName = 'Unknown';
        _deviceOS = 'Unknown';
        _isLoading = false;
      });
      print('Error loading device info: $e');
    }
  }

  Widget _buildDeviceInfoRow(BuildContext context, String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: ColorPalette.textSecondary,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            value ?? 'Unknown',
            style: TextStyle(
              fontSize: 15.sp,
              color: ColorPalette.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Placeholder for request action
  void _requestDeviceChange() {
    // TODO: Implement logic for requesting device change (e.g., show dialog, call API)
    print('Request for device change tapped');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle( color: ColorPalette.textPrimary, fontWeight: FontWeight.w600, fontSize: 18.sp,),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: ColorPalette.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Reusable Profile Header
                const ProfileHeaderWidget(
                    // Pass actual user data if available/needed
                ),
                SizedBox(height: 30.h),

                // "Devices" Section Header (matching Language screen style)
                Padding(
                  padding: EdgeInsets.only(bottom: 15.h),
                  child: Row(
                    children: [
                      Text( 'Devices', style: TextStyle( fontSize: 15.sp, color: ColorPalette.textPrimary,),),
                      const Spacer(),
                      Icon( CupertinoIcons.chevron_down, size: 20.sp, color: ColorPalette.iconGrey.withValues(alpha: 0.8),),
                    ],
                  ),
                ),
                Divider(height: 1.h, color: Colors.grey[200]),
                SizedBox(height: 30.h),

                // --- Device Information Section ---
                Text(
                  'Device information',
                  // Add textAlign here for explicit centering if text wraps
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: ColorPalette.textPrimary),
                ),
                
                SizedBox(height: 15.h),

                _buildDeviceInfoRow(context, 'Name', _deviceName),

                SizedBox(height: 10.h),

                _buildDeviceInfoRow(context, 'Operating System', _deviceOS),

                // --- End Device Information Section ---

                const Spacer(), 

                // --- Request Button ---
                Padding(
                  padding: EdgeInsets.only(bottom: 25.h, top: 15.h), // Adjust padding
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.darkBlue,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50.h), // Make button wide
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r), // Consistent rounding
                      ),
                      textStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _requestDeviceChange,
                    child: const Text('Request for device change'),
                  ),
                ),
              ],
            ),
        ),
    );
  }
}
