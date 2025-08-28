import 'package:flutter/material.dart';
import 'package:attendance_app/core/services/device_identifier_service.dart';
import 'package:attendance_app/core/utils/error_message_helper.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logger/logger.dart';

class FirstTimeDeviceRegistrationDialog extends StatefulWidget {
  final String studentIndex;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const FirstTimeDeviceRegistrationDialog({
    super.key,
    required this.studentIndex,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<FirstTimeDeviceRegistrationDialog> createState() => _FirstTimeDeviceRegistrationDialogState();
}

class _FirstTimeDeviceRegistrationDialogState extends State<FirstTimeDeviceRegistrationDialog> {
  final DeviceIdentifierService _deviceService = DeviceIdentifierService();
  final Logger _logger = Logger();

  bool _isRegistering = false;
  String? _deviceName;
  String? _deviceOs;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceName = await _deviceService.getDeviceName();
      final deviceOs = await _deviceService.getOsVersion();
      setState(() {
        _deviceName = deviceName ?? 'Unknown Device';
        _deviceOs = deviceOs ?? 'Unknown OS';
      });
    } catch (e) {
      _logger.e('Error loading device info: $e');
    }
  }

  Future<void> _registerDevice() async {
    setState(() {
      _isRegistering = true;
    });

    try {
      await _deviceService.registerFirstTimeDevice(widget.studentIndex);
      widget.onSuccess();
    } on DeviceRegistrationException catch (e) {
      _logger.e('Device registration error: ${e.errorCode} - ${e.message}');

      final userMessage = ErrorMessageHelper.getDeviceRegistrationErrorMessage(e.errorCode, e.message);

      if (mounted) {
        if (e.errorCode == 'DEVICE_ALREADY_REGISTERED') {
          // Show a specific dialog for this case
          _showAlreadyRegisteredDialog();
        } else {
          _showErrorSnackBar(userMessage, ErrorMessageHelper.isRetryableError(e.errorCode));
        }
      }
    } catch (e) {
      _logger.e('Unexpected error registering device: $e');
      if (mounted) {
        _showErrorSnackBar('An unexpected error occurred. Please try again.', true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message, bool showRetry) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: showRetry ? 4 : 3),
        action: showRetry ? SnackBarAction(label: 'Retry', textColor: Colors.white, onPressed: _registerDevice) : null,
      ),
    );
  }

  void _showAlreadyRegisteredDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Device Already Registered',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: ColorPalette.textPrimary),
            ),
            content: Text(
              'You already have a registered device for attendance. To change devices, please go to Settings > Device Management and request a device change.',
              style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close this dialog
                  widget.onCancel(); // Close the registration dialog
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _handleCancel() {
    if (_isRegistering) {
      // If registration is in progress, we should still allow cancellation
      // but inform the user that the process will be cancelled
      widget.onCancel();
    } else {
      widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Register Your Device',
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: ColorPalette.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For security purposes, this device needs to be registered for attendance verification.',
            style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary),
          ),
          SizedBox(height: 16.h),
          Text(
            'Device Information:',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: ColorPalette.textPrimary),
          ),
          SizedBox(height: 8.h),
          Text(
            'Name: ${_deviceName ?? 'Loading...'}',
            style: TextStyle(fontSize: 13.sp, color: ColorPalette.textSecondary),
          ),
          Text(
            'OS: ${_deviceOs ?? 'Loading...'}',
            style: TextStyle(fontSize: 13.sp, color: ColorPalette.textSecondary),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: ColorPalette.lightestBlue,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: ColorPalette.lightBlue),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: ColorPalette.darkBlue, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'This is a one-time registration. Future device changes will require approval.',
                    style: TextStyle(fontSize: 12.sp, color: ColorPalette.darkBlue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _handleCancel,
          child: const Text('Cancel', style: TextStyle(color: ColorPalette.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _isRegistering ? null : _registerDevice,
          style: ElevatedButton.styleFrom(backgroundColor: ColorPalette.darkBlue, foregroundColor: Colors.white),
          child:
              _isRegistering
                  ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Register Device'),
        ),
      ],
    );
  }
}
