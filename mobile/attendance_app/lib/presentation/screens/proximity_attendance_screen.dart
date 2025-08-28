import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/services/ble_service.dart';
import '../../core/theme/color_palette.dart';
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

  AttendanceVerificationStatus _verificationStatus = AttendanceVerificationStatus.pending;
  BeaconDetection? _currentDetection;
  Timer? _verificationTimer;
  Duration _remainingTime = const Duration(seconds: 30);
  bool _isScanning = false;
  bool _permissionsGranted = false;
  String _statusMessage = "Checking Bluetooth permissions...";
  String? _permissionError;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupStreams();
    // Don't start verification immediately - wait for permissions
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
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
        setState(() {
          _verificationStatus = status;
        });
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
        sessionId: widget.sessionToken, // Use sessionToken as sessionId
        verificationDuration: const Duration(seconds: 30),
      );
    } catch (e) {
      setState(() {
        _statusMessage = "Error: ${e.toString()}";
        _verificationStatus = AttendanceVerificationStatus.failed;
        _isScanning = false;
      });
    }
  }

  void _startCountdownTimer() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingTime = Duration(seconds: 30 - timer.tick);
          if (_remainingTime.inSeconds <= 0) {
            timer.cancel();
          }
        });
      }
    });
  }

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
        break;
      case AttendanceVerificationStatus.failed:
        _showFailureDialog("Verification failed - please ensure you remain in the classroom");
        break;
      case AttendanceVerificationStatus.timeout:
        _showFailureDialog("Verification timeout - beacon not detected consistently");
        break;
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
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32.sp),
                SizedBox(width: 8.w),
                const Text('Attendance Verified!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Your presence in ${widget.className} has been confirmed through beacon proximity verification.'),
                SizedBox(height: 16.h),
                Text('Room: ${widget.expectedRoomId}', style: TextStyle(fontWeight: FontWeight.bold)),
                if (_currentDetection != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'Average distance: ${_currentDetection!.estimatedDistance.toStringAsFixed(1)}m',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Continue'),
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
            title: Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 32.sp),
                SizedBox(width: 8.w),
                const Text('Verification Failed'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                SizedBox(height: 16.h),
                const Text('Please try again or contact your professor.'),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Retry')),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Color _getStatusColor() {
    if (_currentDetection == null) return Colors.orange;

    switch (_currentDetection!.proximity) {
      case ProximityLevel.near:
        return Colors.green;
      case ProximityLevel.medium:
        return Colors.blue;
      case ProximityLevel.far:
        return Colors.orange;
      case ProximityLevel.outOfRange:
        return Colors.red;
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
      _permissionsGranted = true;
      _statusMessage = "Permissions granted! Starting proximity verification...";
    });
    // Now that permissions are granted, start the verification
    _startProximityVerification();
  }

  void _onPermissionError(String error) {
    setState(() {
      _permissionError = error;
      _statusMessage = "Permission error: $error";
      _verificationStatus = AttendanceVerificationStatus.failed;
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
      backgroundColor: ColorPalette.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              _buildHeader(),
              SizedBox(height: 32.h),
              Expanded(
                child: _buildVerificationContent(),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) => NavigationHelpers.handleNavigation(context, index),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Proximity Attendance',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: ColorPalette.textPrimary,
          ),
        ),
        IconButton(
          onPressed: () {
            // Add functionality for settings or info
          },
          icon: Icon(Icons.settings, size: 24.sp, color: ColorPalette.iconColor),
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
                  child: Icon(_getStatusIcon(), size: 80.sp, color: _getStatusColor()),
                ),
              ),
        ),

        SizedBox(height: 40.h),

        // Status message - Fixed overflow for long messages
        Text(
          _statusMessage,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: ColorPalette.textPrimary),
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: 24.h),

        // Detection details - Fixed overflow in rows
        if (_currentDetection != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDetailRow('Room:', _currentDetection!.roomId),
                SizedBox(height: 8.h),
                _buildDetailRow(
                  'Distance:',
                  '${_currentDetection!.estimatedDistance.toStringAsFixed(1)}m',
                ),
                SizedBox(height: 8.h),
                _buildDetailRow('Signal:', '${_currentDetection!.rssi} dBm'),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],

        // Countdown timer
        Text(
          'Time remaining: ${_remainingTime.inSeconds}s',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: ColorPalette.textSecondary,
          ),
        ),

        SizedBox(height: 16.h),

        // Progress bar
        AnimatedBuilder(
          animation: _progressAnimation,
          builder:
              (context, child) => Container(
                width: double.infinity,
                height: 8.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1.0 - _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
        ),

        SizedBox(height: 60.h),
        // Extra spacing for better scrolling
      ],
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: () {
            _proximityService.stopAttendanceVerification();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          ),
          child: Text('Cancel Verification', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
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
          child: Text(label, style: TextStyle(fontSize: 14.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        SizedBox(width: 8.w),
        Flexible(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
