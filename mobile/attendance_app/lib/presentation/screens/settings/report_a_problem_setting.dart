import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/utils/notification_helper.dart';
import 'package:attendance_app/data/repositories/report_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

// Widgets
import 'package:attendance_app/presentation/widgets/specific/profile_header_widget.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // State for category dropdown
  String? _selectedCategory;
  final List<String> _problemCategories = [
    'QR Scan Issue',
    'Schedule Error',
    'Login/Account Problem',
    'App Bug/Crash',
    'Feature Request',
    'Other',
  ];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Submit report using proper repository
  Future<void> _submitReport() async {
    // 1. Prevent multiple submissions
    if (_isSubmitting) return;

    // 2. Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_selectedCategory == null) {
      if (mounted) {
        NotificationHelper.showWarning(context, 'Please select a category before submitting the report.');
      }
      return;
    }

    // 3. Set submitting state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // 4. Get device and app info
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();
      String deviceInfoString = 'Unknown Device';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceInfoString = '${androidInfo.brand} ${androidInfo.model} (Android ${androidInfo.version.release})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceInfoString = '${iosInfo.name} ${iosInfo.model} (iOS ${iosInfo.systemVersion})';
      }

      // 5. Submit report using repository
      final reportRepository = locator<ReportRepository>();
      final reportId = await reportRepository.submitReport(
        reportType: _selectedCategory!,
        priority: 'medium',
        // Default priority
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        deviceInfo: deviceInfoString,
        userInfo: 'App Version: ${packageInfo.version} (${packageInfo.buildNumber})',
      );

      if (mounted) {
        // Success notification - this will be expandable due to the length
        NotificationHelper.showSuccess(
          context,
          'Your report has been successfully submitted! Thank you for helping us improve the app. Your report ID is: $reportId. We will review your submission and get back to you if additional information is needed. You can reference this ID when contacting support.',
          duration: const Duration(seconds: 6),
          expandable: true,
        );

        // Clear form and navigate back
        _titleController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategory = null;
        });

        // Wait a bit before popping
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        // Error notification - this will also be expandable due to length
        NotificationHelper.showError(
          context,
          'Failed to submit your report. Please check your internet connection and try again. If the problem persists, you can contact support directly. Error details: ${e.toString()}',
          duration: const Duration(seconds: 8),
          expandable: true,
        );
      }
    } finally {
      // 6. Reset submitting state
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Report a Problem', // Specific title
          style: TextStyle(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600, fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: ColorPalette.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(color: ColorPalette.textPrimary),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: ProfileHeaderWidget()),
              // SizedBox(height: 30.h),

              // "Report a problem" Section Header
              Padding(
                padding: EdgeInsets.only(bottom: 15.h, top: 10.h), // Adjusted padding
                child: Row(
                  children: [
                    Text('Report a problem', style: TextStyle(fontSize: 15.sp, color: ColorPalette.textPrimary)),
                    const Spacer(),
                    Icon(CupertinoIcons.chevron_down, size: 20.sp, color: ColorPalette.iconGrey.withValues(alpha: 0.8)),
                  ],
                ),
              ),

              Divider(height: 1.h, color: Colors.grey[200]),

              SizedBox(height: 15.h),

              // --- Category Dropdown ---
              Text(
                'Category',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorPalette.textPrimary),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items:
                    _problemCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, style: TextStyle(fontSize: 14.sp)),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select category',
                  hintStyle: TextStyle(fontSize: 14.sp, color: ColorPalette.iconGrey),
                  filled: true,
                  fillColor: Colors.white,
                  // White background for dropdown
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: ColorPalette.placeholderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: ColorPalette.placeholderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: ColorPalette.darkBlue, width: 1.5.w),
                  ),
                ),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),

              SizedBox(height: 20.h),

              // --- Title Field ---
              Text(
                'Title',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorPalette.textPrimary),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter a brief title for the problem',
                  hintStyle: TextStyle(fontSize: 14.sp, color: ColorPalette.iconGrey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: ColorPalette.placeholderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: ColorPalette.placeholderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: ColorPalette.darkBlue, width: 1.5.w),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20.h),

              // --- Description Field ---
              Text(
                'Description',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorPalette.textPrimary),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Please describe the problem in detail...',
                  hintStyle: TextStyle(fontSize: 14.sp, color: ColorPalette.iconGrey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: ColorPalette.placeholderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: ColorPalette.placeholderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: ColorPalette.darkBlue, width: 1.5.w),
                  ),
                ),
                maxLines: 5,
                minLines: 3,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
              ),

              SizedBox(height: 30.h),

              // --- Submit Button ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.darkBlue,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                onPressed: _isSubmitting ? null : _submitReport,
                child:
                    _isSubmitting
                        ? SizedBox(
                          // Show progress indicator when submitting
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                        : const Text('Submit Report'),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
