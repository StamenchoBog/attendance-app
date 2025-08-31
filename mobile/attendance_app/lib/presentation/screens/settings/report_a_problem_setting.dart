import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/core/utils/notification_helper.dart';
import 'package:attendance_app/data/repositories/report_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/core/services/device_identifier_service.dart';

// Widgets
import 'package:attendance_app/presentation/widgets/specific/profile_header_widget.dart';
import 'package:attendance_app/data/models/report_enums.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';

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
      final reportRepository = locator<ReportRepository>();
      final user = Provider.of<UserProvider>(context, listen: false).currentUser;

      // Get student index from current user
      if (user?.id == null) {
        throw Exception('User information not available');
      }

      // Get device ID from registered device
      final deviceIdentifierService = DeviceIdentifierService();
      final registeredDevice = await deviceIdentifierService.getRegisteredDevice(user!.id);
      final deviceId = registeredDevice['id']; // This will be null if no device is registered

      // 5. Submit report using repository with foreign keys
      final reportId = await reportRepository.submitReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        reportType: _mapCategoryToReportType(_selectedCategory!),
        priority: ReportPriority.medium,
        // Default to medium priority for user reports
        studentIndex: user.id,
        // Required foreign key
        deviceId: deviceId, // Optional foreign key
      );

      if (mounted && reportId != null) {
        // Success notification with copy functionality for report ID
        NotificationHelper.showSuccessWithCopy(
          context,
          'Your report has been successfully submitted! Thank you for helping us improve the app. Your report ID is: $reportId. We will review your submission and get back to you if additional information is needed. You can reference this ID when contacting support.',
          duration: const Duration(seconds: 6),
          copyableText: reportId,
          copyLabel: 'Copy Report ID',
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
      } else if (mounted) {
        // Handle case where reportId is null
        NotificationHelper.showError(
          context,
          'Your report was submitted but we could not generate a report ID. Please contact support if you need to reference this submission.',
          duration: const Duration(seconds: 5),
        );
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

  ReportType _mapCategoryToReportType(String category) {
    switch (category) {
      case 'QR Scan Issue':
      case 'Schedule Error':
      case 'Login/Account Problem':
        return ReportType.attendanceIssue;
      case 'App Bug/Crash':
        return ReportType.bug;
      case 'Feature Request':
        return ReportType.featureRequest;
      case 'Other':
      default:
        return ReportType.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.pureWhite,
      appBar: AppBar(
        title: Text(
          'Report a Problem',
          style: AppTextStyles.heading3.copyWith(color: ColorPalette.textPrimary, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: ColorPalette.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: ColorPalette.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: const IconThemeData(color: ColorPalette.textPrimary),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20, vertical: AppConstants.spacing12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(child: ProfileHeaderWidget()),

              // "Report a problem" Section Header
              Padding(
                padding: EdgeInsets.only(bottom: AppConstants.spacing16, top: AppConstants.spacing12),
                child: Row(
                  children: [
                    Text('Report a problem', style: AppTextStyles.bodyLarge.copyWith(color: ColorPalette.textPrimary)),
                    const Spacer(),
                    Icon(
                      CupertinoIcons.chevron_down,
                      size: AppConstants.iconSizeMedium,
                      color: ColorPalette.iconGrey.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),

              Divider(height: 1.h, color: ColorPalette.dividerColor),

              UIHelpers.verticalSpace(AppConstants.spacing16),

              // --- Category Dropdown ---
              Text(
                'Category',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: ColorPalette.textPrimary),
              ),
              UIHelpers.verticalSpace(AppConstants.spacing8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items:
                    _problemCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textPrimary),
                        ),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select category',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.placeholderGrey),
                  filled: true,
                  fillColor: ColorPalette.pureWhite,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing16,
                    vertical: AppConstants.spacing12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                    borderSide: BorderSide(color: ColorPalette.placeholderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                    borderSide: BorderSide(color: ColorPalette.placeholderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                    borderSide: BorderSide(color: ColorPalette.darkBlue, width: 1.5.w),
                  ),
                ),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),

              UIHelpers.verticalSpace(AppConstants.spacing20),

              // --- Title Field ---
              Text(
                'Title',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: ColorPalette.textPrimary),
              ),
              UIHelpers.verticalSpace(AppConstants.spacing8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter a brief title for the problem',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.placeholderGrey),
                  filled: true,
                  fillColor: ColorPalette.pureWhite,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing16,
                    vertical: AppConstants.spacing12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                    borderSide: BorderSide(color: ColorPalette.placeholderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                    borderSide: BorderSide(color: ColorPalette.placeholderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
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

              UIHelpers.verticalSpace(AppConstants.spacing20),

              // --- Description Field ---
              Text(
                'Description',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: ColorPalette.textPrimary),
              ),
              UIHelpers.verticalSpace(AppConstants.spacing8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Please describe the problem in detail...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.placeholderGrey),
                  filled: true,
                  fillColor: ColorPalette.pureWhite,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppConstants.spacing16,
                    vertical: AppConstants.spacing12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                    borderSide: BorderSide(color: ColorPalette.placeholderGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                    borderSide: BorderSide(color: ColorPalette.placeholderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
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

              UIHelpers.verticalSpace(AppConstants.spacing32),

              // --- Submit Button ---
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.darkBlue,
                  foregroundColor: ColorPalette.pureWhite,
                  minimumSize: Size(double.infinity, AppConstants.buttonHeight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius12)),
                  textStyle: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                ),
                onPressed: _isSubmitting ? null : _submitReport,
                child:
                    _isSubmitting
                        ? SizedBox(
                          width: AppConstants.iconSizeMedium,
                          height: AppConstants.iconSizeMedium,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: ColorPalette.pureWhite),
                        )
                        : const Text('Submit Report'),
              ),

              UIHelpers.verticalSpace(AppConstants.spacing20),
            ],
          ),
        ),
      ),
    );
  }
}
