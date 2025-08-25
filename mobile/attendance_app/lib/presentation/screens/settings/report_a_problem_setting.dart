import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  // Placeholder for submit action
  Future<void> _submitReport() async {
  // 1. Prevent multiple submissions
  if (_isSubmitting) return;

  // 2. Validate form
  if (!(_formKey.currentState?.validate() ?? false)) {
    print('Form validation failed');
    return; // Stop if validation fails
  }
  if (_selectedCategory == null) {
    if (mounted) { // Check if widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category.'), backgroundColor: Colors.orange),
        );
    }
      return; // Stop if category not selected
  }

  // 3. Set submitting state and disable button
  setState(() { _isSubmitting = true; });

  // 4. Prepare data and make API call
  // TODO: Replace with your actual API endpoint
  final url = Uri.parse('https://your-backend-api.com/api/v1/report-problem');
  final headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    // TODO: Add Authorization header if needed
    // 'Authorization': 'Bearer YOUR_AUTH_TOKEN',
  };

  // TODO: Get actual User ID, App Version, Device Info dynamically
  // You might use packages like package_info_plus, device_info_plus
  final String id = "user_123";
  final String name = "User 1234";
  final String appVersionPlaceholder = "1.0.0";
  final String deviceInfoPlaceholder = "Mock Device";

  final body = jsonEncode({
    'userId': id,
    'name': name,
    'category': _selectedCategory!,
    'title': _titleController.text.trim(),
    'description': _descriptionController.text.trim(),
    'appVersion': appVersionPlaceholder,
    'deviceInfo': deviceInfoPlaceholder,
    'timestamp': DateTime.now().toIso8601String(), // Include timestamp
  });

  try {
    print("Sending report to API...");
    print("URL: $url");
    print("Headers: $headers");
    print("Body: $body");

    final response = await http.post(url, headers: headers, body: body)
                      .timeout(const Duration(seconds: 15)); // Add timeout

    print("API Response Status Code: ${response.statusCode}");
    // print("API Response Body: ${response.body}"); // Uncomment for debugging

    // 5. Handle response
    if (mounted) { // Check if widget is still mounted before showing SnackBar
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!'), backgroundColor: Colors.green),
        );
        // Optionally clear form and navigate back after success
        _titleController.clear();
        _descriptionController.clear();
        setState(() { _selectedCategory = null; });
          // Wait a bit before popping
        await Future.delayed(const Duration(seconds: 1));
        if(mounted) Navigator.of(context).pop();

      } else {
        // Failure - Show error based on status code or response body
          String errorMessage = 'Failed to submit report. Server error: ${response.statusCode}.';
          try {
            // Try to parse error message from backend if available
            final responseData = jsonDecode(response.body);
            errorMessage = responseData['message'] ?? errorMessage;
          } catch (e) { /* Ignore parsing errors */ }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }

  } catch (e) {
    // Handle network errors, timeouts, etc.
    print("Error submitting report: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit report. Check connection: $e'), backgroundColor: Colors.red),
      );
    }
  } finally {
    // 6. Reset submitting state regardless of success/failure
    if (mounted) {
        setState(() { _isSubmitting = false; });
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
          style: TextStyle( color: ColorPalette.textPrimary, fontWeight: FontWeight.w600, fontSize: 18.sp,),
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
                    Text(
                      'Report a problem',
                      style: TextStyle( fontSize: 15.sp, color: ColorPalette.textPrimary,),
                    ),
                    const Spacer(),
                    Icon( CupertinoIcons.chevron_down, size: 20.sp, color: ColorPalette.iconGrey.withValues(alpha: 0.8),),
                  ],
                ),
              ),

              Divider(height: 1.h, color: Colors.grey[200]),

              SizedBox(height: 15.h),

              // --- Category Dropdown ---
              Text( 'Category', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorPalette.textPrimary),),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _problemCategories.map((String category) {
                  return DropdownMenuItem<String>( value: category, child: Text(category, style: TextStyle(fontSize: 14.sp)),);
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() { _selectedCategory = newValue; });
                },
                decoration: InputDecoration(
                  hintText: 'Select category',
                  hintStyle: TextStyle(fontSize: 14.sp, color: ColorPalette.iconGrey),
                  filled: true, fillColor: Colors.white, // White background for dropdown
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder( borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: ColorPalette.placeholderGrey),),
                  enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: ColorPalette.placeholderGrey),),
                  focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: ColorPalette.darkBlue, width: 1.5.w),),
                ),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),

              SizedBox(height: 20.h),

              // --- Title Field ---
              Text( 'Title', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorPalette.textPrimary),),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter a brief title for the problem',
                  hintStyle: TextStyle(fontSize: 14.sp, color: ColorPalette.iconGrey),
                  filled: true, fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder( borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: ColorPalette.placeholderGrey),),
                  enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: ColorPalette.placeholderGrey),),
                  focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: ColorPalette.darkBlue, width: 1.5.w),),
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
              Text( 'Description', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorPalette.textPrimary),),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Please describe the problem in detail...',
                  hintStyle: TextStyle(fontSize: 14.sp, color: ColorPalette.iconGrey),
                  filled: true, fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder( borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: ColorPalette.placeholderGrey),),
                  enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: ColorPalette.placeholderGrey),),
                  focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: ColorPalette.darkBlue, width: 1.5.w),),
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
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(12.r),),
                  textStyle: TextStyle( fontSize: 16.sp, fontWeight: FontWeight.w600,),
                ),
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting
                       ? SizedBox( // Show progress indicator when submitting
                          width: 20.w, height: 20.w,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white,)
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