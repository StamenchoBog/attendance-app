import 'package:flutter/material.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/core/services/device_identifier_service.dart';
import 'package:attendance_app/core/utils/notification_helper.dart';
import 'package:logger/logger.dart';

class FirstTimeDeviceRegistrationDialog extends StatefulWidget {
  final String studentIndex;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const FirstTimeDeviceRegistrationDialog({super.key, required this.studentIndex, this.onSuccess, this.onCancel});

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

      if (mounted) {
        setState(() {
          _deviceName = deviceName ?? 'Unknown Device';
          _deviceOs = deviceOs ?? 'Unknown OS';
        });
      }
    } catch (e) {
      _logger.e('Error loading device info: $e');
    }
  }

  Future<void> _registerDevice() async {
    if (_isRegistering) return;

    setState(() {
      _isRegistering = true;
    });

    try {
      await _deviceService.registerFirstTimeDevice(widget.studentIndex);

      if (mounted) {
        NotificationHelper.showSuccess(
          context,
          'Device registered successfully! You can now use this device for attendance verification.',
        );
        widget.onSuccess?.call();
      }
    } catch (e) {
      _logger.e('Error registering device: $e');
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
        NotificationHelper.showError(context, 'Failed to register device. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius12)),
      title: Row(
        children: [
          Icon(Icons.smartphone, color: ColorPalette.darkBlue, size: AppConstants.iconSizeMedium),
          UIHelpers.horizontalSpace(AppConstants.spacing8),
          Expanded(
            child: Text(
              'Register Device',
              style: AppTextStyles.heading3.copyWith(color: ColorPalette.primaryTextColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This appears to be your first time using this device for attendance. Would you like to register it for future use?',
            style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.secondaryTextColor),
          ),
          UIHelpers.verticalSpace(AppConstants.spacing16),
          Container(
            padding: EdgeInsets.all(AppConstants.spacing12),
            decoration: BoxDecoration(
              color: ColorPalette.backgroundColor,
              borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
              border: Border.all(color: ColorPalette.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Information:',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: ColorPalette.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                UIHelpers.verticalSpace(AppConstants.spacing8),
                Row(
                  children: [
                    Icon(Icons.phone_android, size: AppConstants.iconSizeSmall, color: ColorPalette.iconGrey),
                    UIHelpers.horizontalSpace(AppConstants.spacing8),
                    Expanded(
                      child: Text(
                        _deviceName ?? 'Loading...',
                        style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.primaryTextColor),
                      ),
                    ),
                  ],
                ),
                UIHelpers.verticalSpace(AppConstants.spacing4),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: AppConstants.iconSizeSmall, color: ColorPalette.iconGrey),
                    UIHelpers.horizontalSpace(AppConstants.spacing8),
                    Expanded(
                      child: Text(
                        _deviceOs ?? 'Loading...',
                        style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.primaryTextColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: _isRegistering ? null : _registerDevice,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPalette.darkBlue,
            foregroundColor: ColorPalette.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius8)),
          ),
          child: Text('Register', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}
