import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/utils/notification_helper.dart';
import 'package:attendance_app/data/repositories/report_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/data/models/report_enums.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/data/models/professor.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

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
  bool _includeUserInfo = true;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Submit Report',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: ColorPalette.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorPalette.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: ColorPalette.lightestBlue,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: ColorPalette.lightBlue.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bug_report, color: ColorPalette.darkBlue, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Help us improve the app by reporting issues or suggesting features',
                        style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Report Type
              _buildSectionTitle('Report Type'),
              SizedBox(height: 12.h),
              _buildReportTypeSelector(),

              SizedBox(height: 24.h),

              // Priority
              _buildSectionTitle('Priority'),
              SizedBox(height: 12.h),
              _buildPrioritySelector(),

              SizedBox(height: 24.h),

              // Title
              _buildSectionTitle('Title'),
              SizedBox(height: 8.h),
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

              SizedBox(height: 20.h),

              // Description
              _buildSectionTitle('Description'),
              SizedBox(height: 8.h),
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

              SizedBox(height: 20.h),

              // Steps to reproduce (conditional)
              if (_selectedType == ReportType.bug ||
                  _selectedType == ReportType.attendanceIssue ||
                  _selectedType == ReportType.deviceIssue) ...[
                _buildSectionTitle('Steps to Reproduce'),
                SizedBox(height: 8.h),
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
                SizedBox(height: 20.h),
              ],

              // Additional info options
              _buildSectionTitle('Additional Information'),
              SizedBox(height: 12.h),
              _buildCheckboxTile(
                title: 'Include device information',
                subtitle: 'Device model, OS version, app version',
                value: _includeDeviceInfo,
                onChanged: (value) => setState(() => _includeDeviceInfo = value ?? true),
              ),
              _buildCheckboxTile(
                title: 'Include user information',
                subtitle: 'User type and index (no personal data)',
                value: _includeUserInfo,
                onChanged: (value) => setState(() => _includeUserInfo = value ?? true),
              ),

              SizedBox(height: 32.h),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.darkBlue,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child:
                      _isSubmitting
                          ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                          : Text(
                            'Submit Report',
                            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                          ),
                ),
              ),

              SizedBox(height: 16.h),

              // Privacy note
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.privacy_tip_outlined, color: Colors.grey.shade600, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Your report will be sent to our development team. We respect your privacy and will only use the information provided to improve the app.',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600, height: 1.3),
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
    return Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: ColorPalette.textPrimary));
  }

  Widget _buildReportTypeSelector() {
    return Column(
      children:
          ReportType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isSelected ? ColorPalette.lightestBlue : Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: isSelected ? ColorPalette.darkBlue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getIconForReportType(type),
                      color: isSelected ? ColorPalette.darkBlue : Colors.grey.shade600,
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTitleForReportType(type),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? ColorPalette.darkBlue : ColorPalette.textPrimary,
                            ),
                          ),
                          Text(
                            _getDescriptionForReportType(type),
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected) Icon(Icons.check_circle, color: ColorPalette.darkBlue, size: 20.sp),
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
                  margin: EdgeInsets.only(right: priority != ReportPriority.values.last ? 8.w : 0),
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: isSelected ? _getColorForPriority(priority).withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected ? _getColorForPriority(priority) : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    _getTitleForPriority(priority),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
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
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: ColorPalette.darkBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        contentPadding: EdgeInsets.all(16.w),
      ),
      style: TextStyle(fontSize: 14.sp, color: ColorPalette.textPrimary),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: CheckboxListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorPalette.textPrimary),
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
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

      // Get user info if allowed
      String? userInfo;
      if (_includeUserInfo) {
        final user = Provider.of<UserProvider>(context, listen: false).currentUser;
        if (user is Student) {
          userInfo = 'Student (${user.studentIndex})';
        } else if (user is Professor) {
          userInfo = 'Professor (${user.id})';
        }
      }

      // Get device info if allowed - optimized to be cached
      String? deviceInfo;
      if (_includeDeviceInfo) {
        deviceInfo = await _getDeviceInfo();
      }

      // Submit report to backend
      final reportId = await reportRepository.submitReport(
        reportType: _selectedType.value,
        priority: _selectedPriority.value,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        stepsToReproduce: _stepsController.text.trim().isNotEmpty ? _stepsController.text.trim() : null,
        userInfo: userInfo,
        deviceInfo: deviceInfo,
      );

      if (mounted) {
        // Success notification - make it expandable to show full report ID and details
        NotificationHelper.showSuccess(
          context,
          'Your report has been successfully submitted! Thank you for helping us improve the app. Your complete report ID is: $reportId. Please save this ID for future reference if you need to contact support about this report. We will review your submission and may reach out if additional information is needed.',
          duration: const Duration(seconds: 6),
          expandable: true,
        );
        Navigator.of(context).pop();
      }
    } on ReportValidationException catch (e) {
      if (mounted) {
        NotificationHelper.showWarning(context, 'Validation Error: ${e.message}', duration: const Duration(seconds: 4));
      }
    } on ReportSubmissionException catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to submit your report.';
        if (e.statusCode == 400) {
          errorMessage += ' Please check your input and try again.';
        } else if (e.statusCode == 401) {
          errorMessage += ' Please log in again and try again.';
        } else if (e.statusCode == 429) {
          errorMessage += ' Too many requests. Please wait a moment and try again.';
        } else if (e.statusCode != null && e.statusCode! >= 500) {
          errorMessage += ' Server error. Please try again later.';
        }
        errorMessage += ' Error: ${e.message}';

        NotificationHelper.showError(
          context,
          errorMessage,
          duration: const Duration(seconds: 8),
          expandable: true,
          actionLabel: 'Retry',
          onAction: _submitReport,
        );
      }
    } catch (e) {
      if (mounted) {
        // Generic error notification with troubleshooting guidance
        NotificationHelper.showError(
          context,
          'An unexpected error occurred while submitting your report. Please check your internet connection and try again. If the problem persists, please contact support. Error details: ${e.toString()}',
          duration: const Duration(seconds: 8),
          expandable: true,
          actionLabel: 'Retry',
          onAction: _submitReport,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Cached device info to avoid repeated calls
  String? _cachedDeviceInfo;

  Future<String?> _getDeviceInfo() async {
    if (_cachedDeviceInfo != null) {
      return _cachedDeviceInfo;
    }

    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        _cachedDeviceInfo =
            'Android ${androidInfo.version.release} - ${androidInfo.model} (SDK ${androidInfo.version.sdkInt})';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        _cachedDeviceInfo = 'iOS ${iosInfo.systemVersion} - ${iosInfo.model}';
      }
      return _cachedDeviceInfo;
    } catch (e) {
      // Fallback if device info fails
      return 'Device info unavailable';
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
        return Colors.green;
      case ReportPriority.medium:
        return Colors.orange;
      case ReportPriority.high:
        return Colors.red;
      case ReportPriority.critical:
        return Colors.purple;
    }
  }
}
