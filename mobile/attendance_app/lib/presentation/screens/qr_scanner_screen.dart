import 'package:attendance_app/core/services/ble_service.dart';
import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  final String studentIndex;
  final String deviceId;

  const QrScannerScreen({
    super.key,
    required this.studentIndex,
    required this.deviceId,
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final AttendanceRepository _attendanceRepository = locator<AttendanceRepository>();
  final BleService _bleService = BleService();
  bool _isProcessing = false;
  String _statusMessage = 'Scanning for QR Code...';

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _showResultDialog(String title, String message) async {
    if (!mounted) return;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back from scanner
            },
          ),
        ],
      ),
    );
  }

  void _handleDetection(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final String? qrToken = capture.barcodes.first.rawValue;
    if (qrToken == null) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'QR Code detected. Registering attendance...';
    });

    try {
      // Step 1: Register attendance
      final attendanceId = await _attendanceRepository.registerAttendance(
        token: qrToken,
        studentIndex: widget.studentIndex,
      );

      setState(() {
        _statusMessage = 'Registered! Now scanning for classroom beacon...';
      });

      // Step 2: Scan for BLE beacon and get proximity
      final proximity = await _bleService.getProximity();

      setState(() {
        _statusMessage = 'Beacon found! Confirming attendance...';
      });

      // Step 3: Confirm attendance
      await _attendanceRepository.confirmAttendance(
        attendanceId: attendanceId,
        proximity: proximity,
      );

      _showResultDialog('Success', 'Attendance verified successfully!');

    } catch (e) {
      _showResultDialog('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleDetection,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      _statusMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
