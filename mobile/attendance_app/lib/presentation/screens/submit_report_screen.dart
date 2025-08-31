import 'package:flutter/material.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/core/utils/notification_helper.dart';
import 'package:attendance_app/data/repositories/report_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/data/models/report_enums.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/core/services/device_identifier_service.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();

  ReportType _selectedType = ReportType.bug;
  ReportPriority _selectedPriority = ReportPriority.medium;
  bool _isSubmitting = false;
  bool _includeDeviceInfo = true;

  final DeviceIdentifierService _deviceIdentifierService = DeviceIdentifierService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.pureWhite,
      appBar: AppBar(
        title: Text(
          'Submit Report',
          style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w600, color: ColorPalette.textPrimary),
        ),
        backgroundColor: ColorPalette.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ColorPalette.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(AppConstants.spacing16),
                decoration: BoxDecoration(
                  color: ColorPalette.lightestBlue,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                  border: Border.all(color: ColorPalette.lightBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bug_report, color: ColorPalette.darkBlue, size: AppConstants.iconSizeMedium),
                    UIHelpers.horizontalSpace(AppConstants.spacing12),
                    Expanded(
                      child: Text(
                        'Help us improve the app by reporting issues or suggesting features',
                        style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              UIHelpers.verticalSpace(AppConstants.spacing24),

              // Report Type
              _buildSectionTitle('Report Type'),
              UIHelpers.verticalSpace(AppConstants.spacing12),
              _buildReportTypeSelector(),

              UIHelpers.verticalSpace(AppConstants.spacing24),

              // Priority
              _buildSectionTitle('Priority'),
              UIHelpers.verticalSpace(AppConstants.spacing12),
              _buildPrioritySelector(),

              UIHelpers.verticalSpace(AppConstants.spacing24),

              // Title
              _buildSectionTitle('Title'),
              UIHelpers.verticalSpace(AppConstants.spacing8),
              _buildTextField(
                controller: _titleController,
                hintText: 'Brief summary of the issue or request',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 5) {
                    return 'Title must be at least 5 characters';
                  }
                  return null;
                },
              ),

              UIHelpers.verticalSpace(AppConstants.spacing20),

              // Description
              _buildSectionTitle('Description'),
              UIHelpers.verticalSpace(AppConstants.spacing8),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'Provide detailed description of the issue or feature request',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),

              UIHelpers.verticalSpace(AppConstants.spacing20),

              // Steps to reproduce (conditional)
              if (_selectedType == ReportType.bug ||
                  _selectedType == ReportType.attendanceIssue ||
                  _selectedType == ReportType.deviceIssue) ...[
                _buildSectionTitle('Steps to Reproduce'),
                UIHelpers.verticalSpace(AppConstants.spacing8),
                _buildTextField(
                  controller: _stepsController,
                  hintText: 'Step 1: ...\nStep 2: ...\nStep 3: ...',
                  maxLines: 3,
                  validator: (value) {
                    if (_selectedType == ReportType.bug && (value == null || value.trim().isEmpty)) {
                      return 'Please provide steps to reproduce the bug';
                    }
                    return null;
                  },
                ),
                UIHelpers.verticalSpace(AppConstants.spacing20),
              ],

              // Additional info options
              _buildSectionTitle('Additional Information'),
              UIHelpers.verticalSpace(AppConstants.spacing12),
              _buildCheckboxTile(
                title: 'Include device information',
                subtitle: 'Device model, OS version, app version',
                value: _includeDeviceInfo,
                onChanged: (value) => setState(() => _includeDeviceInfo = value ?? true),
              ),

              UIHelpers.verticalSpace(AppConstants.spacing32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.darkBlue,
                    disabledBackgroundColor: ColorPalette.disabledColor,
                    padding: EdgeInsets.symmetric(vertical: AppConstants.spacing16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadius8)),
                  ),
                  child:
                      _isSubmitting
                          ? SizedBox(
                            height: AppConstants.iconSizeMedium,
                            width: AppConstants.iconSizeMedium,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(ColorPalette.pureWhite),
                            ),
                          )
                          : Text(
                            'Submit Report',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: ColorPalette.pureWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),

              UIHelpers.verticalSpace(AppConstants.spacing16),

              // Privacy note
              Container(
                padding: EdgeInsets.all(AppConstants.spacing12),
                decoration: BoxDecoration(
                  color: ColorPalette.screenBackgroundLight,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
                  border: Border.all(color: ColorPalette.dividerColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.privacy_tip_outlined, color: ColorPalette.iconGrey, size: AppConstants.iconSizeSmall),
                    UIHelpers.horizontalSpace(AppConstants.spacing8),
                    Expanded(
                      child: Text(
                        'Your report will be sent to our development team. We respect your privacy and will only use the information provided to improve the app.',
                        style: AppTextStyles.caption.copyWith(color: ColorPalette.iconGrey, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: ColorPalette.textPrimary),
    );
  }

  Widget _buildReportTypeSelector() {
    return Column(
      children:
          ReportType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                margin: EdgeInsets.only(bottom: AppConstants.spacing8),
                padding: EdgeInsets.all(AppConstants.spacing16),
                decoration: BoxDecoration(
                  color: isSelected ? ColorPalette.lightestBlue : ColorPalette.pureWhite,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
                  border: Border.all(
                    color: isSelected ? ColorPalette.darkBlue : ColorPalette.dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForReportType(type),
                      color: isSelected ? ColorPalette.darkBlue : ColorPalette.iconGrey,
                      size: AppConstants.iconSizeMedium,
                    ),
                    UIHelpers.horizontalSpace(AppConstants.spacing12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTitleForReportType(type),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isSelected ? ColorPalette.darkBlue : ColorPalette.textPrimary,
                            ),
                          ),
                          Text(
                            _getDescriptionForReportType(type),
                            style: AppTextStyles.caption.copyWith(color: ColorPalette.iconGrey),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: ColorPalette.darkBlue, size: AppConstants.iconSizeMedium),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children:
          ReportPriority.values.map((priority) {
            final isSelected = _selectedPriority == priority;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPriority = priority),
                child: Container(
                  margin: EdgeInsets.only(right: priority != ReportPriority.values.last ? AppConstants.spacing8 : 0),
                  padding: EdgeInsets.symmetric(vertical: AppConstants.spacing12, horizontal: AppConstants.spacing8),
                  decoration: BoxDecoration(
                    color: isSelected ? _getColorForPriority(priority).withValues(alpha: 0.1) : ColorPalette.pureWhite,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
                    border: Border.all(
                      color: isSelected ? _getColorForPriority(priority) : ColorPalette.dividerColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    _getTitleForPriority(priority),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? _getColorForPriority(priority) : ColorPalette.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.placeholderGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
          borderSide: const BorderSide(color: ColorPalette.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
          borderSide: const BorderSide(color: ColorPalette.darkBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius8),
          borderSide: const BorderSide(color: ColorPalette.errorColor, width: 2),
        ),
        contentPadding: EdgeInsets.all(AppConstants.spacing16),
      ),
      style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textPrimary),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppConstants.spacing8),
      child: CheckboxListTile(
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500, color: ColorPalette.textPrimary),
        ),
        subtitle: Text(subtitle, style: AppTextStyles.caption.copyWith(color: ColorPalette.iconGrey)),
        value: value,
        onChanged: onChanged,
        activeColor: ColorPalette.darkBlue,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final reportRepository = locator<ReportRepository>();
      final user = Provider.of<UserProvider>(context, listen: false).currentUser;

      // Get student index from current user
      if (user?.id == null) {
        throw Exception('User information not available');
      }

      // Get device ID if device info is included
      String? deviceId;
      if (_includeDeviceInfo) {
        try {
          final registeredDevice = await _deviceIdentifierService.getRegisteredDevice(user!.id);
          final rawDeviceId = registeredDevice['id'];
          // Only use device ID if we have a valid UUID (not the raw device identifier)
          if (rawDeviceId != null && rawDeviceId.toString().trim().isNotEmpty) {
            // Check if it looks like a UUID (contains hyphens and is proper length)
            final deviceIdStr = rawDeviceId.toString().trim();
            if (deviceIdStr.contains('-') && deviceIdStr.length >= 32) {
              deviceId = deviceIdStr;
            } else {
              // If it's not a UUID format, don't send device ID to avoid foreign key constraint violation
              debugPrint('Device ID is not in UUID format, skipping: $deviceIdStr');
              deviceId = null;
            }
          }
        } catch (e) {
          // If device info retrieval fails, continue without deviceId
          debugPrint('Failed to get device info: $e');
          deviceId = null;
        }
      }

      final reportId = await reportRepository.submitReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        reportType: _selectedType,
        priority: _selectedPriority,
        stepsToReproduce: _stepsController.text.trim().isNotEmpty ? _stepsController.text.trim() : null,
        studentIndex: user!.id,
        // Required foreign key
        deviceId: deviceId, // Optional foreign key
      );

      if (mounted && reportId != null) {
        // Success notification with copy functionality for report ID
        NotificationHelper.showSuccessWithCopy(
          context,
          'Your report has been successfully submitted! Thank you for helping us improve the app. Your complete report ID is: $reportId. Please save this ID for future reference if you need to contact support about this report. We will review your submission and may reach out if additional information is needed.',
          duration: const Duration(seconds: 6),
          copyableText: reportId,
          copyLabel: 'Copy Report ID',
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        // Handle case where reportId is null
        NotificationHelper.showError(
          context,
          'Your report was submitted but we could not generate a report ID. Please contact support if you need to reference this submission.',
          duration: const Duration(seconds: 5),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        // Use standardized error handling
        NotificationHelper.showError(
          context,
          'An unexpected error occurred while submitting your report. Please check your internet connection and try again. If the problem persists, please contact support. Error details: ${e.toString()}',
          duration: const Duration(seconds: 8),
          expandable: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  IconData _getIconForReportType(ReportType type) {
    switch (type) {
      case ReportType.bug:
        return Icons.bug_report;
      case ReportType.featureRequest:
        return Icons.lightbulb_outline;
      case ReportType.attendanceIssue:
        return Icons.how_to_reg_outlined;
      case ReportType.deviceIssue:
        return Icons.phone_android;
      case ReportType.other:
        return Icons.help_outline;
    }
  }

  String _getTitleForReportType(ReportType type) {
    switch (type) {
      case ReportType.bug:
        return 'Bug Report';
      case ReportType.featureRequest:
        return 'Feature Request';
      case ReportType.attendanceIssue:
        return 'Attendance Issue';
      case ReportType.deviceIssue:
        return 'Device Issue';
      case ReportType.other:
        return 'Other';
    }
  }

  String _getDescriptionForReportType(ReportType type) {
    switch (type) {
      case ReportType.bug:
        return 'Something is not working correctly';
      case ReportType.featureRequest:
        return 'Suggest a new feature or improvement';
      case ReportType.attendanceIssue:
        return 'Problems with attendance verification';
      case ReportType.deviceIssue:
        return 'Device registration or verification problems';
      case ReportType.other:
        return 'General feedback or other issues';
    }
  }

  String _getTitleForPriority(ReportPriority priority) {
    switch (priority) {
      case ReportPriority.low:
        return 'Low';
      case ReportPriority.medium:
        return 'Medium';
      case ReportPriority.high:
        return 'High';
      case ReportPriority.critical:
        return 'Critical';
    }
  }

  Color _getColorForPriority(ReportPriority priority) {
    switch (priority) {
      case ReportPriority.low:
        return ColorPalette.successColor;
      case ReportPriority.medium:
        return ColorPalette.warningColor;
      case ReportPriority.high:
        return ColorPalette.errorColor;
      case ReportPriority.critical:
        return ColorPalette.criticalColor;
    }
  }
}
