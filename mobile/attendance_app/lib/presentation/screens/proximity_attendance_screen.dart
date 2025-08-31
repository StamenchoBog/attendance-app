import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/ble_service.dart';
import '../../core/services/proximity_attendance_service.dart';
import '../../core/theme/color_palette.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/ui_helpers.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/beacon_models.dart';
import '../widgets/static/bottom_nav_bar.dart';
import '../widgets/static/helpers/navigation_helpers.dart';
import '../widgets/bluetooth_permission_handler.dart';

class ProximityAttendanceScreen extends StatefulWidget {
  final String sessionToken;
  final String expectedRoomId;
  final String className;
  final int attendanceId;

  const ProximityAttendanceScreen({
    super.key,
    required this.sessionToken,
    required this.expectedRoomId,
    required this.className,
    required this.attendanceId,
  });

  @override
  State<ProximityAttendanceScreen> createState() => _ProximityAttendanceScreenState();
}

class _ProximityAttendanceScreenState extends State<ProximityAttendanceScreen> with TickerProviderStateMixin {
  final int _selectedIndex = 1;
  final ProximityAttendanceService _proximityService = ProximityAttendanceService();

  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  BeaconDetection? _currentDetection;
  final Duration _remainingTime = const Duration(minutes: 5);
  bool _isScanning = false;
  String _statusMessage = "Checking Bluetooth permissions...";

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupStreams();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(duration: AppConstants.animationMedium, vsync: this);
    _progressController = AnimationController(duration: const Duration(seconds: 30), vsync: this);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.linear));

    _pulseController.repeat(reverse: true);
  }

  void _setupStreams() {
    // Listen to beacon detections
    _proximityService.beaconDetections.listen((detection) {
      if (mounted) {
        setState(() {
          _currentDetection = detection;
          _statusMessage = _getStatusMessage(detection);
        });
      }
    });

    // Listen to verification status
    _proximityService.verificationStatus.listen((status) {
      if (mounted) {
        setState(() {});
        _handleVerificationResult(status);
      }
    });
  }

  Future<void> _startProximityVerification() async {
    try {
      setState(() {
        _isScanning = true;
        _statusMessage = "Starting proximity verification...";
      });

      _progressController.forward();
      _startCountdownTimer();

      // Start the proximity verification process with simplified parameters
      await _proximityService.startAttendanceVerification(
        sessionId: widget.sessionToken,
        verificationDuration: const Duration(seconds: 30),
      );
    } catch (e) {
      setState(() {
        _statusMessage = "Error: ${e.toString()}";
        _isScanning = false;
      });
    }
  }

  void _startCountdownTimer() {}

  String _getStatusMessage(BeaconDetection detection) {
    final distance = detection.estimatedDistance.toStringAsFixed(1);
    switch (detection.proximity) {
      case ProximityLevel.near:
        return "Perfect! You're in the classroom (${distance}m)";
      case ProximityLevel.medium:
        return "Good proximity detected (${distance}m)";
      case ProximityLevel.far:
        return "Move closer to the classroom (${distance}m)";
      case ProximityLevel.outOfRange:
        return "Too far from classroom beacon";
    }
  }

  void _handleVerificationResult(AttendanceVerificationStatus status) {
    switch (status) {
      case AttendanceVerificationStatus.verified:
        _showSuccessDialog();
      case AttendanceVerificationStatus.failed:
        _showFailureDialog("Verification failed - please ensure you remain in the classroom");
      case AttendanceVerificationStatus.timeout:
        _showFailureDialog("Verification timeout - beacon not detected consistently");
      case AttendanceVerificationStatus.pending:
        break;
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius16)),
            title: Row(
              children: [
                Icon(Icons.check_circle, color: ColorPalette.successColor, size: AppConstants.iconSizeLarge),
                UIHelpers.horizontalSpace(AppConstants.spacing8),
                Text('Attendance Verified!', style: AppTextStyles.heading3.copyWith(color: ColorPalette.textPrimary)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your presence in ${widget.className} has been confirmed through beacon proximity verification.',
                  style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary),
                ),
                UIHelpers.verticalSpace(AppConstants.spacing16),
                Text(
                  'Room: ${widget.expectedRoomId}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorPalette.textPrimary,
                  ),
                ),
                if (_currentDetection != null) ...[
                  UIHelpers.verticalSpace(AppConstants.spacing8),
                  Text(
                    'Average distance: ${_currentDetection!.estimatedDistance.toStringAsFixed(1)}m',
                    style: AppTextStyles.caption.copyWith(color: ColorPalette.textSecondary),
                  ),
                ],
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.darkBlue,
                  foregroundColor: ColorPalette.pureWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius8)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Continue', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
    );
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius16)),
            title: Row(
              children: [
                Icon(Icons.error, color: ColorPalette.errorColor, size: AppConstants.iconSizeLarge),
                UIHelpers.horizontalSpace(AppConstants.spacing8),
                Text('Verification Failed', style: AppTextStyles.heading3.copyWith(color: ColorPalette.textPrimary)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary)),
                UIHelpers.verticalSpace(AppConstants.spacing16),
                Text(
                  'Please try again or contact your professor.',
                  style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: ColorPalette.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Retry', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.darkBlue,
                  foregroundColor: ColorPalette.pureWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius8)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
    );
  }

  Color _getStatusColor() {
    if (_currentDetection == null) return ColorPalette.warningColor;
    switch (_currentDetection!.proximity) {
      case ProximityLevel.near:
        return ColorPalette.successColor;
      case ProximityLevel.medium:
        return ColorPalette.darkBlue;
      case ProximityLevel.far:
        return ColorPalette.warningColor;
      case ProximityLevel.outOfRange:
        return ColorPalette.errorColor;
    }
  }

  IconData _getStatusIcon() {
    if (_currentDetection == null) return Icons.search;
    switch (_currentDetection!.proximity) {
      case ProximityLevel.near:
        return Icons.check_circle;
      case ProximityLevel.medium:
        return Icons.location_on;
      case ProximityLevel.far:
        return Icons.location_searching;
      case ProximityLevel.outOfRange:
        return Icons.location_off;
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      handleBottomNavigation(context, index);
    }
  }

  void _onPermissionsGranted() {
    setState(() {
      _statusMessage = "Permissions granted! Starting proximity verification...";
    });
    // Now that permissions are granted, start the verification
    _startProximityVerification();
  }

  void _onPermissionError(String error) {
    setState(() {
      _statusMessage = "Permission error: $error";
    });
  }

  @override
  Widget build(BuildContext context) {
    return BluetoothPermissionHandler(
      onPermissionsGranted: _onPermissionsGranted,
      onPermissionError: _onPermissionError,
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: ColorPalette.screenBackgroundLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing24, vertical: AppConstants.spacing20),
          child: Column(
            children: [
              _buildHeader(),
              UIHelpers.verticalSpace(AppConstants.spacing32),
              Expanded(child: _buildVerificationContent()),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => handleBottomNavigation(context, index),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Proximity Attendance',
          style: AppTextStyles.heading2.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
        ),
        IconButton(
          onPressed: () {
            // Add functionality for settings or info
          },
          icon: Icon(Icons.settings, size: AppConstants.iconSizeMedium, color: ColorPalette.iconGrey),
        ),
      ],
    );
  }

  Widget _buildVerificationContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pulse animation circle
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder:
              (context, child) => Transform.scale(
                scale: _isScanning ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor().withValues(alpha: 0.2),
                    border: Border.all(color: _getStatusColor(), width: 3),
                  ),
                  child: Icon(_getStatusIcon(), size: AppConstants.iconSizeXLarge * 2, color: _getStatusColor()),
                ),
              ),
        ),

        UIHelpers.verticalSpace(AppConstants.spacing40),

        // Status message - Fixed overflow for long messages
        Text(
          _statusMessage,
          style: AppTextStyles.heading3.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),

        UIHelpers.verticalSpace(AppConstants.spacing24),

        // Detection details - Fixed overflow in rows
        if (_currentDetection != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppConstants.spacing16),
            decoration: UIHelpers.roundedCardDecoration,
            child: Column(
              children: [
                _buildDetailRow('Room:', _currentDetection!.roomId),
                UIHelpers.verticalSpace(AppConstants.spacing8),
                _buildDetailRow('Distance:', '${_currentDetection!.estimatedDistance.toStringAsFixed(1)}m'),
                UIHelpers.verticalSpace(AppConstants.spacing8),
                _buildDetailRow('Signal:', '${_currentDetection!.rssi} dBm'),
              ],
            ),
          ),
          UIHelpers.verticalSpace(AppConstants.spacing24),
        ],

        // Countdown timer
        Text(
          'Time remaining: ${_remainingTime.inSeconds}s',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w500, color: ColorPalette.textSecondary),
        ),

        UIHelpers.verticalSpace(AppConstants.spacing16),

        // Progress bar
        AnimatedBuilder(
          animation: _progressAnimation,
          builder:
              (context, child) => Container(
                width: double.infinity,
                height: AppConstants.spacing8,
                decoration: BoxDecoration(
                  color: ColorPalette.dividerColor,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1.0 - _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius4),
                    ),
                  ),
                ),
              ),
        ),

        UIHelpers.verticalSpace(AppConstants.spacing64),
        // Extra spacing for better scrolling
      ],
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.spacing20,
        AppConstants.spacing12,
        AppConstants.spacing20,
        AppConstants.spacing20,
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppConstants.buttonHeight,
        child: ElevatedButton(
          onPressed: () {
            _proximityService.stopAttendanceVerification();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorPalette.disabledColor,
            foregroundColor: ColorPalette.pureWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius16)),
          ),
          child: Text('Cancel Verification', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  // Helper method to build detail rows with proper overflow handling
  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        UIHelpers.horizontalSpace(AppConstants.spacing8),
        Flexible(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: ColorPalette.textPrimary),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
