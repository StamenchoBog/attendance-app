import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/services/ble_service.dart';
import '../../core/theme/color_palette.dart';

class BluetoothPermissionHandler extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPermissionsGranted;
  final Function(String error)? onPermissionError;

  const BluetoothPermissionHandler({
    super.key,
    required this.child,
    this.onPermissionsGranted,
    this.onPermissionError,
  });

  @override
  State<BluetoothPermissionHandler> createState() => _BluetoothPermissionHandlerState();
}

class _BluetoothPermissionHandlerState extends State<BluetoothPermissionHandler> {
  final ProximityAttendanceService _proximityService = ProximityAttendanceService();
  bool _isCheckingPermissions = true;
  bool _permissionsGranted = false;
  PermissionRequestResult? _permissionResult;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isCheckingPermissions = true;
    });

    try {
      final result = await _proximityService.checkAndRequestPermissions();
      setState(() {
        _permissionResult = result;
        _permissionsGranted = result.success;
        _isCheckingPermissions = false;
      });

      if (result.success) {
        widget.onPermissionsGranted?.call();
      } else {
        widget.onPermissionError?.call(result.message);
      }
    } catch (e) {
      setState(() {
        _permissionResult = PermissionRequestResult(
          success: false,
          message: "Failed to check permissions: $e",
          canRetry: true,
        );
        _permissionsGranted = false;
        _isCheckingPermissions = false;
      });
      widget.onPermissionError?.call("Permission check failed: $e");
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
    // Re-check permissions after user returns from settings
    Future.delayed(const Duration(seconds: 1), () {
      _checkPermissions();
    });
  }

  Widget _buildPermissionPrompt() {
    if (_isCheckingPermissions) {
      return _buildLoadingState();
    }

    if (_permissionsGranted) {
      return widget.child;
    }

    final result = _permissionResult!;

    return Scaffold(
      backgroundColor: ColorPalette.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bluetooth_disabled,
                size: 80.w,
                color: ColorPalette.errorColor,
              ),
              SizedBox(height: 24.h),
              Text(
                'Bluetooth Permissions Required',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                result.message,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: ColorPalette.secondaryTextColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // Show specific permissions that were denied
              if (result.deniedPermissions.isNotEmpty) ...[
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: ColorPalette.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: ColorPalette.errorColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Denied Permissions:',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorPalette.errorColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ...result.deniedPermissions.map((permission) => Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.close,
                              size: 16.w,
                              color: ColorPalette.errorColor,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _getPermissionDisplayName(permission),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: ColorPalette.errorColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],

              // Action buttons
              if (result.needsSettingsRedirect) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openAppSettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Open Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _checkPermissions,
                    child: const Text('Re-check Permissions'),
                    style: TextButton.styleFrom(
                      foregroundColor: ColorPalette.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                  ),
                ),
              ] else if (result.needsBluetoothEnable) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openAppSettings,
                    icon: const Icon(Icons.bluetooth),
                    label: const Text('Turn On Bluetooth'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _checkPermissions,
                    child: const Text('Check Again'),
                    style: TextButton.styleFrom(
                      foregroundColor: ColorPalette.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                  ),
                ),
              ] else if (result.canRetry) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _checkPermissions,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Request Permissions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorPalette.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: 32.h),

              // Help text
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: ColorPalette.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: ColorPalette.primaryColor,
                      size: 24.w,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Why are these permissions needed?',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorPalette.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'The app needs Bluetooth and Location permissions to detect classroom beacons for attendance verification. This ensures you are physically present in the classroom.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: ColorPalette.secondaryTextColor,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: ColorPalette.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.primaryColor),
              ),
              SizedBox(height: 24.h),
              Text(
                'Checking Bluetooth Permissions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.primaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Please wait while we verify your device permissions...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: ColorPalette.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPermissionDisplayName(String permission) {
    switch (permission) {
      case 'Permission.bluetooth':
        return 'Bluetooth Access';
      case 'Permission.bluetoothScan':
        return 'Bluetooth Scanning';
      case 'Permission.bluetoothConnect':
        return 'Bluetooth Connection';
      case 'Permission.bluetoothAdvertise':
        return 'Bluetooth Advertising';
      case 'Permission.location':
        return 'Location Access';
      default:
        return permission.replaceAll('Permission.', '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildPermissionPrompt();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
