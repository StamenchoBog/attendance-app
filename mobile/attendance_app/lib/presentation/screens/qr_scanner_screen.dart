import 'package:attendance_app/core/services/ble_service.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/utils/error_handler.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/core/services/permission_service.dart';
import 'package:attendance_app/data/models/proximity_verification_models.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:logger/logger.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScannerScreen extends StatefulWidget {
  final String studentIndex;
  final String deviceId;

  const QrScannerScreen({super.key, required this.studentIndex, required this.deviceId});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final AttendanceRepository _attendanceRepository = locator<AttendanceRepository>();
  final BleService _bleService = BleService();
  final Logger _logger = Logger();
  bool _isProcessing = false;
  bool _permissionsChecked = false;
  String _statusMessage = 'Checking permissions...';

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.on && mounted) {
        setState(() {
          _statusMessage = 'Scanning for QR Code...';
          _permissionsChecked = true;
        });
      }
    });
    _checkPermissionsOnInit();
  }

  Future<void> _checkPermissionsOnInit() async {
    _logger.i('QR Scanner opened - checking permissions...');

    try {
      // First check if permissions are already granted
      final permissionsGranted = await PermissionService.arePermissionsGranted();

      if (!permissionsGranted) {
        _logger.i('Permissions not granted for QR scanning, requesting...');

        // Update UI to show permission request
        if (mounted) {
          setState(() {
            _statusMessage = 'Requesting permissions...';
          });
        }

        final granted = await PermissionService.requestInitialPermissions(context);

        if (!granted) {
          _logger.w('User denied permissions for QR scanning');
          if (mounted) {
            setState(() {
              _statusMessage = 'Permissions required to scan QR codes';
            });
            _showResultDialog(
              'Permissions Required',
              'Camera and Bluetooth permissions are required to scan QR codes for attendance verification. Please grant the required permissions in Settings and try again.',
            );
          }
          return;
        }
      }

      // Check Bluetooth adapter state
      if (await FlutterBluePlus.isSupported) {
        final adapterState = await FlutterBluePlus.adapterState.first;
        if (adapterState != BluetoothAdapterState.on) {
          _logger.w('Bluetooth is turned off');
          if (mounted) {
            Navigator.of(context).pop(); // Navigate back to the previous screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bluetooth is required for beacon detection. Please enable Bluetooth and try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // Permissions granted and Bluetooth is on, proceed with scanning
      if (mounted) {
        setState(() {
          _permissionsChecked = true;
          _statusMessage = 'Scanning for QR Code...';
        });
      }

      _logger.i('All permissions granted and Bluetooth is ready, QR scanner ready');
    } catch (e) {
      _logger.e('Error checking permissions: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Error checking permissions';
        });
        _showResultDialog(
          'Permission Error',
          'An error occurred while checking permissions. Please restart the app and try again.',
        );
      }
    }
  }

  Future<void> _showBluetoothRequiredDialog() async {
    if (!mounted) return;
    await UIHelpers.showBluetoothRequiredDialog(context);
  }

  Future<void> _openBluetoothSettings() async {
    try {
      // On iOS/Android, opening app settings will let user enable Bluetooth
      await openAppSettings();

      // Wait a moment and then re-check permissions and Bluetooth state
      await Future.delayed(const Duration(seconds: 2));
      _checkPermissionsOnInit();
    } catch (e) {
      _logger.e('Error opening Bluetooth settings: $e');
      if (mounted) {
        setState(() {
          _permissionsChecked = true;
          _statusMessage = 'Please enable Bluetooth manually and restart the app';
        });
      }
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _showResultDialog(
    String title,
    String message, {
    bool hasUpdateOption = false,
    bool isSuccess = false,
    bool isError = false,
  }) async {
    if (!mounted) return;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius12)),
            title: Text(
              title,
              style: AppTextStyles.heading3.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            content: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: ColorPalette.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing24, vertical: AppConstants.spacing12),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  if (isSuccess) {
                    // Navigate back to previous screen when attendance is successfully registered
                    Navigator.of(context).pop();
                  } else if (isError) {
                    // Navigate back to previous screen after error dialog
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'OK',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  void _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final String? qrToken = capture.barcodes.first.rawValue;
    if (qrToken == null) return;

    // Stop the scanner immediately after detecting a QR code to prevent duplicate scans
    await _scannerController.stop();
    _logger.i('Scanner stopped after QR detection');

    setState(() {
      _isProcessing = true;
      _statusMessage = 'QR Code detected. Processing...';
    });

    try {
      // Step 1: Scan for BLE beacon and collect proximity data
      setState(() {
        _statusMessage = 'Scanning for classroom beacon...';
      });

      List<ProximityDetectionRequest>? proximityDetections;
      String? expectedRoomId;

      try {
        // Collect proximity data using the BLE service
        _logger.i('Starting proximity data collection');

        // Use the enhanced beacon detection to get full beacon data including real RSSI
        final beaconDetection = await _bleService.detectBeaconProximity(timeout: const Duration(seconds: 30));

        if (beaconDetection != null) {
          _logger.i(
            'Beacon detected with full data: Room=${beaconDetection.roomId}, RSSI=${beaconDetection.rssi}, Distance=${beaconDetection.estimatedDistance}m',
          );

          final roomId = beaconDetection.roomId;
          final proximityLevel = beaconDetection.proximity.name;
          final realRssi = beaconDetection.rssi;
          final realDistance = beaconDetection.estimatedDistance;

          // Validate beacon data
          if (roomId.isEmpty || proximityLevel.isEmpty) {
            _logger.w('Invalid beacon data: roomId or proximityLevel is empty');
            setState(() {
              _statusMessage = 'Invalid beacon data detected. Skipping...';
            });
          } else {
            // Create a ProximityDetectionRequest with REAL beacon data
            final proximityRequest = ProximityDetectionRequest(
              studentIndex: widget.studentIndex,
              sessionToken: qrToken,
              beaconDeviceId: beaconDetection.deviceId,
              detectedRoomId: roomId,
              rssi: realRssi,
              proximityLevel: proximityLevel.toUpperCase(),
              estimatedDistance: realDistance,
              detectionTimestamp: beaconDetection.timestamp,
              beaconType: beaconDetection.beaconType.toUpperCase(),
            );

            proximityDetections = [proximityRequest];
            expectedRoomId = roomId;

            setState(() {
              _statusMessage =
                  'Beacon detected! Room: $roomId, RSSI: ${realRssi}dBm, Distance: ${realDistance.toStringAsFixed(1)}m, Type: ${beaconDetection.beaconType}';
            });
            _logger.i(
              'Proximity data collected successfully with real RSSI: $realRssi dBm, BeaconType: ${beaconDetection.beaconType}',
            );
          }
        } else {
          _logger.w('No beacon detected - proceeding with attendance registration without proximity data');
          setState(() {
            _statusMessage = 'No beacon detected - registering attendance without proximity data...';
          });
        }
      } catch (e) {
        _logger.e('Error during beacon detection: $e');
        // Continue with registration even if beacon detection fails
        setState(() {
          _statusMessage = 'Beacon detection error, continuing with registration...';
        });
      }

      // Step 2: Register attendance with proximity data if available
      setState(() {
        _statusMessage = 'Registering attendance...';
      });

      final attendanceId = await _attendanceRepository.registerAttendance(
        token: qrToken,
        studentIndex: widget.studentIndex,
        deviceId: widget.deviceId,
        proximityDetections: proximityDetections,
        expectedRoomId: expectedRoomId,
        verificationDurationSeconds: proximityDetections != null ? 10 : null,
        // 10 seconds if we have data
        context: null,
      );

      // Check if registration was successful
      if (attendanceId == null) {
        throw Exception('Registration failed. Please try again.');
      }

      // Reset processing state before showing success dialog
      setState(() {
        _isProcessing = false;
      });

      // Display success message with proximity information
      String successMessage = 'Attendance was registered successfully!';
      _showResultDialog('Success', successMessage, isSuccess: true);
    } catch (e) {
      // Reset processing state before showing error dialog
      setState(() {
        _isProcessing = false;
      });

      String errorMessage = e.toString();
      String dialogTitle = 'Error';
      _logger.e('QR Scanner error: $errorMessage');

      // Clean up the error message if it starts with "Exception: "
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }

      // Enhanced error handling for attendance token specific errors
      if (_isAttendanceTokenError(errorMessage)) {
        final result = _getAttendanceTokenErrorMessage(errorMessage);
        dialogTitle = result['title']!;
        errorMessage = result['message']!;

        // Check if this is an attendance update case
        final bool isUpdateCase = dialogTitle == 'Update Attendance';
        _showResultDialog(dialogTitle, errorMessage, hasUpdateOption: isUpdateCase, isError: true);
        return; // Exit early since we've shown the dialog
      } else if (errorMessage.contains('Failed to read HTTP message') ||
          errorMessage.contains('proximityDetections') ||
          errorMessage.contains('proximity data') ||
          errorMessage.contains('verificationDurationSeconds')) {
        // Handle proximity/beacon data specific errors
        dialogTitle = 'Proximity Detection Issue';
        errorMessage =
            'There was an issue processing beacon proximity data. Your attendance may still be registered. Please ensure you are in the correct classroom and try again if needed.';
        _showResultDialog(dialogTitle, errorMessage, isError: true);
        return;
      } else if (errorMessage.contains('beacon')) {
        // Handle other beacon-related errors
        dialogTitle = 'Beacon Detection Issue';
        errorMessage =
            'There was an issue with beacon detection. Your attendance has been registered, but location verification may be incomplete. Please ensure you are in the correct classroom.';
        _showResultDialog(dialogTitle, errorMessage, isError: true);
        return;
      } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
        dialogTitle = 'Connection Error';
        errorMessage = 'Network connection error. Please check your internet connection and try again.';
      } else if (errorMessage.contains('timeout')) {
        dialogTitle = 'Timeout Error';
        errorMessage = 'The request took too long to complete. Please try scanning the QR code again.';
      } else if (errorMessage.contains('ApiException') || errorMessage.contains('DioException')) {
        dialogTitle = 'Connection Error';
        // Use the ErrorHandler to get a clean, user-friendly message
        final cleanMessage = ErrorHandler.getErrorMessage(errorMessage);
        errorMessage =
            cleanMessage.isNotEmpty
                ? cleanMessage
                : 'Unable to connect to the server. Please check your internet connection and try again.';
      } else if (errorMessage.contains('Registration failed')) {
        dialogTitle = 'Registration Failed';
        errorMessage = 'Failed to register attendance. Please ensure the QR code is valid and try again.';
      }

      _showResultDialog(dialogTitle, errorMessage, isError: true);
    } finally {
      // Scanner is already stopped, so we don't need to reset processing state
      // The result dialog will navigate away from the screen
      _logger.i('QR processing completed, scanner remains stopped');
    }
  }

  /// Checks if the error is related to attendance token issues
  bool _isAttendanceTokenError(String errorMessage) {
    final tokenErrorKeywords = [
      'token',
      'invalid',
      'expired',
      'not found',
      'unauthorized',
      'forbidden',
      'bad request',
      '400',
      '401',
      '403',
      '404',
      'already used',
      'already scanned',
      'class not started',
      'class ended',
      'attendance closed',
    ];

    final lowerErrorMessage = errorMessage.toLowerCase();
    return tokenErrorKeywords.any((keyword) => lowerErrorMessage.contains(keyword));
  }

  /// Returns improved error messages for attendance token related errors
  Map<String, String> _getAttendanceTokenErrorMessage(String originalError) {
    final lowerError = originalError.toLowerCase();

    // Invalid or expired token
    if (lowerError.contains('invalid') && lowerError.contains('token') ||
        lowerError.contains('expired') && lowerError.contains('token') ||
        lowerError.contains('token') && lowerError.contains('not found')) {
      return {
        'title': 'Invalid QR Code',
        'message':
            'This QR code is invalid or has expired. Please ask your professor to generate a new QR code for attendance.',
      };
    }

    // Handle "already registered attendance" as an update case
    if (lowerError.contains('already registered') ||
        (lowerError.contains('already') && lowerError.contains('attendance')) ||
        lowerError.contains('duplicate attendance')) {
      return {
        'title': 'Update Attendance',
        'message':
            'You have already registered attendance for this session. Scanning this new QR code will update your attendance status. Would you like to continue?',
      };
    }

    // Class not started yet
    if (lowerError.contains('class') && lowerError.contains('not started') || lowerError.contains('too early')) {
      return {
        'title': 'Class Not Started',
        'message':
            'The class has not started yet. Please wait until the class begins before scanning the attendance QR code.',
      };
    }

    // Class already ended
    if (lowerError.contains('class') && (lowerError.contains('ended') || lowerError.contains('finished')) ||
        lowerError.contains('attendance') && lowerError.contains('closed') ||
        lowerError.contains('too late')) {
      return {
        'title': 'Attendance Closed',
        'message':
            'The attendance period for this class has ended. Please contact your professor if you need to register your attendance.',
      };
    }

    // Unauthorized access
    if (lowerError.contains('401') || lowerError.contains('unauthorized')) {
      return {
        'title': 'Authentication Error',
        'message':
            'You are not authorized to register attendance for this class. Please ensure you are enrolled in the course.',
      };
    }

    // Forbidden access
    if (lowerError.contains('403') || lowerError.contains('forbidden')) {
      return {
        'title': 'Access Denied',
        'message':
            'You do not have permission to register attendance for this class. Please verify your enrollment status.',
      };
    }

    // Bad request / validation error
    if (lowerError.contains('400') || lowerError.contains('bad request') || lowerError.contains('validation')) {
      return {
        'title': 'Invalid Request',
        'message':
            'The QR code format is not recognized. Please ensure you are scanning a valid attendance QR code generated by your professor.',
      };
    }

    // Generic token error fallback
    if (lowerError.contains('token')) {
      return {
        'title': 'QR Code Error',
        'message':
            'There was an issue with the attendance QR code. Please try scanning again or ask your professor for a new QR code.',
      };
    }

    // Default fallback for unrecognized attendance errors
    return {
      'title': 'Attendance Error',
      'message':
          'An error occurred while processing your attendance. Please try scanning the QR code again or contact your professor for assistance.',
    };
  }

  double _getEstimatedDistance(String proximityLevel) {
    // Simple mapping of proximity levels to estimated distances in meters
    switch (proximityLevel) {
      case 'IMMEDIATE':
        return 0.0;
      case 'NEAR':
        return 1.0;
      case 'FAR':
        return 3.0;
      default:
        return 5.0; // Default to 5 meters for unknown levels
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan QR Code',
          style: AppTextStyles.heading3.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: ColorPalette.textPrimary,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Only show camera scanner if permissions are checked and granted
          if (_permissionsChecked)
            MobileScanner(controller: _scannerController, onDetect: _handleDetection)
          else
            Container(
              color: ColorPalette.pureWhite,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: ColorPalette.darkBlue),
                    UIHelpers.verticalSpace(AppConstants.spacing16),
                    Text(
                      _statusMessage,
                      style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.primaryTextColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: AppConstants.spacing32),
                  padding: EdgeInsets.all(AppConstants.spacing24),
                  decoration: UIHelpers.roundedCardDecoration,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: ColorPalette.darkBlue, strokeWidth: 3),
                      UIHelpers.verticalSpace(AppConstants.spacing20),
                      Text(
                        _statusMessage,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: ColorPalette.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
