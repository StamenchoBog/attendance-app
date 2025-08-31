import 'dart:async';
import 'package:attendance_app/presentation/widgets/specific/profile_header_widget.dart';
import 'package:attendance_app/presentation/widgets/static/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/core/utils/notification_helper.dart';
import 'package:attendance_app/core/services/device_identifier_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../../data/models/student.dart';
import '../../../data/providers/user_provider.dart';

class DevicesOverviewScreen extends StatefulWidget {
  const DevicesOverviewScreen({super.key});

  @override
  State<DevicesOverviewScreen> createState() => _DevicesOverviewScreenState();
}

class _DevicesOverviewScreenState extends State<DevicesOverviewScreen> {
  final DeviceIdentifierService _deviceIdentifierService = DeviceIdentifierService();
  late Future<Map<String, Map<String, String?>>> _deviceInfoFuture;
  final Logger _logger = Logger();
  Timer? _refreshTimer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _deviceInfoFuture = _loadDeviceInfo();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _logger.i("Auto-refreshing device info...");
      if (mounted) {
        setState(() {
          _deviceInfoFuture = _loadDeviceInfo();
        });
      }
    });
  }

  Future<Map<String, Map<String, String?>>> _loadDeviceInfo() async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser as Student?;
    // Fetch both registered and current device info in parallel
    final results = await Future.wait([
      _deviceIdentifierService.getRegisteredDevice(user?.studentIndex),
      _getCurrentDeviceInfo(),
    ]);
    return {'registered': results[0], 'current': results[1]};
  }

  Future<Map<String, String?>> _getCurrentDeviceInfo() async {
    final deviceName = await _deviceIdentifierService.getDeviceName();
    final deviceOS = await _deviceIdentifierService.getOsVersion();
    final deviceId = await _deviceIdentifierService.getPlatformSpecificIdentifier();
    return {'name': deviceName, 'os': deviceOS, 'id': deviceId};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.pureWhite,
      appBar: AppBar(
        title: Text(
          'Devices',
          style: AppTextStyles.heading3.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: ColorPalette.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: ColorPalette.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Map<String, Map<String, String?>>>(
        future: _deviceInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingSkeleton();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load device information.',
                style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary),
              ),
            );
          } else if (snapshot.hasData) {
            final registeredDevice = snapshot.data!['registered']!;
            final currentDevice = snapshot.data!['current']!;
            final bool devicesMatch = registeredDevice['id'] == currentDevice['id'];

            if (devicesMatch) {
              _refreshTimer?.cancel();
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        const ProfileHeaderWidget(),
                        UIHelpers.verticalSpace(AppConstants.spacing24),
                        Text(
                          'For security, your attendance can only be marked from one registered device.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary),
                        ),
                        UIHelpers.verticalSpace(AppConstants.spacing24),
                        _buildDeviceInfoCard(
                          title: 'Registered for Attendance',
                          deviceName: registeredDevice['name'] ?? 'Unknown',
                          deviceOs: registeredDevice['os'] ?? 'Unknown',
                          icon: CupertinoIcons.checkmark_shield_fill,
                          iconColor: ColorPalette.successColor,
                        ),
                        UIHelpers.verticalSpace(AppConstants.spacing16),
                        _buildDeviceInfoCard(
                          title: 'Current Device',
                          deviceName: currentDevice['name'] ?? 'Unknown',
                          deviceOs: currentDevice['os'] ?? 'Unknown',
                          icon: CupertinoIcons.device_phone_portrait,
                          iconColor: ColorPalette.darkBlue,
                        ),
                        UIHelpers.verticalSpace(AppConstants.spacing20),
                        _buildStatusIndicator(devicesMatch),
                      ],
                    ),
                  ),
                  _buildActionButton(devicesMatch),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDeviceInfoCard({
    required String title,
    required String deviceName,
    required String deviceOs,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      elevation: 0,
      color: ColorPalette.lightestBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius12)),
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacing16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: AppConstants.iconSizeLarge),
            UIHelpers.horizontalSpace(AppConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.caption.copyWith(
                      color: ColorPalette.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  UIHelpers.verticalSpace(AppConstants.spacing4),
                  Text(
                    deviceName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: ColorPalette.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  UIHelpers.verticalSpace(2.h),
                  Text(deviceOs, style: AppTextStyles.caption.copyWith(color: ColorPalette.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool devicesMatch) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing12, vertical: AppConstants.spacing8),
      decoration: BoxDecoration(
        color:
            devicesMatch
                ? ColorPalette.successColor.withValues(alpha: 0.1)
                : ColorPalette.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            devicesMatch ? CupertinoIcons.check_mark_circled : CupertinoIcons.exclamationmark_triangle,
            color: devicesMatch ? ColorPalette.successColor : ColorPalette.warningColor,
            size: AppConstants.iconSizeMedium,
          ),
          UIHelpers.horizontalSpace(AppConstants.spacing8),
          Text(
            devicesMatch ? 'Devices Match' : 'Device Mismatch',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color:
                  devicesMatch
                      ? ColorPalette.successColor.withValues(alpha: 0.8)
                      : ColorPalette.warningColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool devicesMatch) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing32, top: AppConstants.spacing16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: devicesMatch || _isSubmitting ? ColorPalette.disabledColor : ColorPalette.darkBlue,
          foregroundColor: ColorPalette.pureWhite,
          minimumSize: Size(double.infinity, AppConstants.buttonHeight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius12)),
          textStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        onPressed:
            devicesMatch || _isSubmitting
                ? null
                : () async {
                  setState(() => _isSubmitting = true);
                  try {
                    final user = Provider.of<UserProvider>(context, listen: false).currentUser as Student?;
                    if (user == null) return;

                    await _deviceIdentifierService.requestDeviceLink(user.studentIndex);

                    if (mounted) {
                      NotificationHelper.showSuccess(context, "Request submitted! It will be processed shortly.");
                    }
                  } catch (e) {
                    if (mounted) {
                      NotificationHelper.showError(context, "Error: ${e.toString()}");
                    }
                  } finally {
                    if (mounted) {
                      setState(() => _isSubmitting = false);
                    }
                  }
                },
        child:
            _isSubmitting
                ? CircularProgressIndicator(color: ColorPalette.pureWhite)
                : Text(devicesMatch ? 'Device Linked' : 'Link This Device'),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
      child: Column(
        children: [
          const ProfileHeaderWidget(),
          UIHelpers.verticalSpace(AppConstants.spacing48),
          const SkeletonLoader(width: double.infinity, height: 80),
          UIHelpers.verticalSpace(AppConstants.spacing16),
          const SkeletonLoader(width: double.infinity, height: 80),
        ],
      ),
    );
  }
}
