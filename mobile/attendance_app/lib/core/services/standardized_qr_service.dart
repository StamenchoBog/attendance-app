import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/color_palette.dart';
import '../../data/repositories/presentation_repository.dart';
import '../../data/services/service_starter.dart';

class StandardizedQRService {
  static final PresentationRepository _presentationRepository = locator<PresentationRepository>();

  /// Standardized QR generation method that includes beacon configuration
  /// This ensures all QR codes work with proximity verification
  static Future<void> generateStandardizedQR({
    required BuildContext context,
    required Map<String, dynamic> classData,
    String beaconMode = 'dedicated', // Default to dedicated beacon
    bool showBeaconModeSelector = true,
  }) async {
    String selectedBeaconMode = beaconMode;

    // Show beacon mode selector if requested
    if (showBeaconModeSelector) {
      selectedBeaconMode = await _showBeaconModeSelector(context) ?? '';
      // If user cancelled the beacon mode selector, don't proceed
      if (selectedBeaconMode.isEmpty) return;
    }

    // Check if it's a past class and ask for confirmation
    final classDateTime = DateTime.parse(classData['date'] ?? DateTime.now().toIso8601String());
    final isPastClass = classDateTime.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    if (isPastClass) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Overwrite Attendance?'),
              content: const Text(
                'This class has already occurred. Generating a new QR code will reset all existing attendance records for this session to "Pending". Are you sure you want to continue?',
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm')),
              ],
            ),
      );
      if (confirmed != true) return;
    }

    // NOW generate the QR code after user has confirmed they want to proceed
    await _generateQRCodeAndShowDialog(context, classData, selectedBeaconMode);
  }

  /// Generate QR code and show the dialog - only called after user confirms
  static Future<void> _generateQRCodeAndShowDialog(
    BuildContext context,
    Map<String, dynamic> classData,
    String beaconMode,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final sessionId = int.parse(classData['professorClassSessionId']);

      // Create presentation session using the correct repository method
      final response = await _presentationRepository.createPresentationSession(sessionId, context: context);

      Navigator.of(context).pop(); // Dismiss loading dialog

      if (response != null && context.mounted) {
        final qrBytes = base64Decode(response['qrCodeBytes'] as String? ?? '');
        final shortKey = response['shortKey'] as String? ?? 'unknown';
        final presentationUrl = '${dotenv.env['PRESENTATION_URL']}/p/$shortKey';
        await _showStandardizedQRDialog(context, qrBytes, presentationUrl, beaconMode, classData);
      } else if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to generate QR code: No response from server')));
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading dialog
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate QR code: $e')));
      }
    }
  }

  /// Show beacon mode selector dialog with modern design
  static Future<String?> _showBeaconModeSelector(BuildContext context) async {
    String selectedMode = 'dedicated';

    return await showDialog<String>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  contentPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  content: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.8, // Limit height to 80% of screen
                      maxWidth: MediaQuery.of(context).size.width * 0.9, // Limit width to 90% of screen
                    ),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with icon
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Icon(Icons.bluetooth_rounded, color: ColorPalette.darkBlue, size: 24.sp),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Proximity Verification',
                                        style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700,
                                          color: ColorPalette.textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Choose beacon mode for attendance verification',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: ColorPalette.textSecondary,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 24.h),

                            Text(
                              'How will students verify their proximity?',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: ColorPalette.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Dedicated Beacon Option
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedMode == 'dedicated' ? ColorPalette.darkBlue : Colors.grey.shade300,
                                  width: selectedMode == 'dedicated' ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                                color:
                                    selectedMode == 'dedicated'
                                        ? ColorPalette.darkBlue.withValues(alpha: 0.05)
                                        : Colors.transparent,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => setState(() => selectedMode = 'dedicated'),
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Padding(
                                    padding: EdgeInsets.all(20.w),
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          value: 'dedicated',
                                          groupValue: selectedMode,
                                          onChanged: (value) => setState(() => selectedMode = value!),
                                          activeColor: ColorPalette.darkBlue,
                                        ),
                                        SizedBox(width: 12.w),
                                        Icon(
                                          Icons.router_rounded,
                                          color:
                                              selectedMode == 'dedicated'
                                                  ? ColorPalette.darkBlue
                                                  : ColorPalette.textSecondary,
                                          size: 28.sp,
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Dedicated Beacon Device',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      selectedMode == 'dedicated'
                                                          ? ColorPalette.darkBlue
                                                          : ColorPalette.textPrimary,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                'Use a physical beacon device placed in the classroom',
                                                style: TextStyle(fontSize: 13.sp, color: ColorPalette.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Professor Phone Option
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedMode == 'phone' ? ColorPalette.darkBlue : Colors.grey.shade300,
                                  width: selectedMode == 'phone' ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(16.r),
                                color:
                                    selectedMode == 'phone'
                                        ? ColorPalette.darkBlue.withValues(alpha: 0.05)
                                        : Colors.transparent,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => setState(() => selectedMode = 'phone'),
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Padding(
                                    padding: EdgeInsets.all(20.w),
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          value: 'phone',
                                          groupValue: selectedMode,
                                          onChanged: (value) => setState(() => selectedMode = value!),
                                          activeColor: ColorPalette.darkBlue,
                                        ),
                                        SizedBox(width: 12.w),
                                        Icon(
                                          Icons.phone_android_rounded,
                                          color:
                                              selectedMode == 'phone'
                                                  ? ColorPalette.darkBlue
                                                  : ColorPalette.textSecondary,
                                          size: 28.sp,
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Use This Phone as Beacon',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      selectedMode == 'phone'
                                                          ? ColorPalette.darkBlue
                                                          : ColorPalette.textPrimary,
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                'Turn your phone into a classroom beacon',
                                                style: TextStyle(fontSize: 13.sp, color: ColorPalette.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Info box for professor phone mode
                            if (selectedMode == 'phone') ...[
                              SizedBox(height: 16.h),
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline_rounded, color: Colors.orange, size: 20.sp),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        'Keep this phone in the classroom during attendance verification',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.orange.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            SizedBox(height: 24.h),

                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(null),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: ColorPalette.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(selectedMode),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorPalette.darkBlue,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                  ),
                                  child: Text(
                                    'Continue',
                                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  /// Show standardized QR dialog with beacon information
  static Future<void> _showStandardizedQRDialog(
    BuildContext context,
    Uint8List qrBytes, // Changed from List<int> to Uint8List
    String presentationUrl,
    String beaconMode,
    Map<String, dynamic> classData,
  ) async {
    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            contentPadding: EdgeInsets.all(16.w),
            title: const Text('Scan QR Code for Attendance', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // QR Code Image - Now properly accepts Uint8List
                Image.memory(qrBytes),
                SizedBox(height: 16.h),

                // Beacon Mode Information
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: ColorPalette.darkBlue.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            beaconMode == 'phone' ? Icons.phone_android : Icons.router,
                            color: ColorPalette.darkBlue,
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Beacon Mode: ${beaconMode == 'phone' ? 'Professor Phone' : 'Dedicated Beacon'}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: ColorPalette.darkBlue,
                            ),
                          ),
                        ],
                      ),
                      if (beaconMode == 'phone') ...[
                        SizedBox(height: 8.h),
                        Text(
                          'Keep this phone in the classroom during attendance verification',
                          style: TextStyle(fontSize: 12.sp, color: ColorPalette.textSecondary),
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Alternative URL option
                Text('Or tap the link to open in a browser:', style: TextStyle(fontSize: 14.sp)),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () async {
                    final url = Uri.parse(presentationUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Could not open the link.')));
                      }
                    }
                  },
                  child: Text(
                    presentationUrl,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.darkBlue,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
          ),
    );
  }
}
