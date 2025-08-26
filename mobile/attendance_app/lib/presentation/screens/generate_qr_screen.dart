import 'dart:convert';
import 'package:attendance_app/data/providers/date_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/color_palette.dart';
import '../../data/models/professor.dart';
import '../../data/providers/user_provider.dart';
import '../../data/repositories/class_session_repository.dart';
import '../../data/services/service_starter.dart';
import '../widgets/static/app_top_bar.dart';
import '../widgets/static/bottom_nav_bar.dart';
import '../widgets/static/helpers/navigation_helpers.dart';

class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({super.key});

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen> {
  final int _selectedIndex = 2;
  final Logger _logger = Logger();
  final ClassSessionRepository _classSessionRepository = locator<ClassSessionRepository>();
  final AttendanceRepository _attendanceRepository = locator<AttendanceRepository>();

  DateProvider? _dateProvider;
  List<dynamic> _classes = [];
  dynamic _selectedClass;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<DateProvider>(context);
    if (provider != _dateProvider) {
      _dateProvider?.removeListener(_loadClassesForDate);
      _dateProvider = provider;
      _dateProvider?.addListener(_loadClassesForDate);
      // Initial load
      _loadClassesForDate();
    }
  }

  @override
  void dispose() {
    _dateProvider?.removeListener(_loadClassesForDate);
    super.dispose();
  }

  Future<void> _loadClassesForDate() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedClass = null;
      _classes = [];
    });

    try {
      final user = Provider.of<UserProvider>(context, listen: false).currentUser as Professor?;
      if (user == null) throw Exception("Professor not logged in");

      final classes = await _classSessionRepository.getProfessorClassSessions(user.id, _dateProvider!.selectedDate);
      if (!mounted) return;
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to load classes for the selected date.";
        _isLoading = false;
      });
      _logger.e(e);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateProvider.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != dateProvider.selectedDate) {
      dateProvider.updateDate(picked);
    }
  }

  Future<void> _generateAndShowQrCode() async {
    if (_selectedClass == null) return;

    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final selectedDate = dateProvider.selectedDate;
    final today = DateTime.now();
    final isPastClass = selectedDate.isBefore(DateTime(today.year, today.month, today.day));

    if (isPastClass) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Overwrite Attendance?'),
          content: const Text('This class has already occurred. Generating a new QR code will reset all existing attendance records for this session to "Pending". Are you sure you want to continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final sessionId = int.parse(_selectedClass['professorClassSessionId']);
      final response = await _attendanceRepository.createPresentationSession(sessionId);

      final qrBytes = base64Decode(response['qrCodeBytes'] as String);
      final shortKey = response['shortKey'] as String;
      
      Navigator.of(context).pop(); // Dismiss loading dialog

      if (mounted) {
        final presentationUrl = '${dotenv.env['PRESENTATION_URL']}/p/$shortKey';
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            contentPadding: EdgeInsets.all(16.w),
            title: const Text('Scan or Share Link', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(qrBytes),
                SizedBox(height: 16.h),
                Text('Or tap the link to open in a browser:', style: TextStyle(fontSize: 14.sp)),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () async {
                    final url = Uri.parse(presentationUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open the link.')),
                        );
                      }
                    }
                  },
                  child: Text(
                    presentationUrl,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.darkBlue,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading dialog
      _logger.e(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate QR code.')),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      handleBottomNavigation(context, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateState = Provider.of<DateProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 15.h),
              const AppTopBar(searchHintText: 'Search...'),
              SizedBox(height: 24.h),
              Text(
                'On-the-Fly QR Code',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorPalette.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Select a scheduled class for today to generate an attendance code.',
                style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary),
              ),
              SizedBox(height: 24.h),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMMM d, yyyy').format(dateState.selectedDate),
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                              ),
                              const Icon(CupertinoIcons.calendar, color: ColorPalette.darkBlue),
                            ],
                          ),
                        ),
                      ),
                      Divider(height: 20.h),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: Text(_errorMessage!)),
                        )
                      else
                        DropdownButtonFormField<dynamic>(
                          value: _selectedClass,
                          hint: const Text('Select a Class Session'),
                          isExpanded: true,
                          decoration: const InputDecoration(border: InputBorder.none),
                          items: _classes.map<DropdownMenuItem<dynamic>>((dynamic classData) {
                            return DropdownMenuItem<dynamic>(
                              value: classData,
                              child: Text(
                                '${classData['subjectName']} (${classData['startTime']} - ${classData['endTime']})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (dynamic newValue) {
                            setState(() {
                              _selectedClass = newValue;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _selectedClass == null ? null : _generateAndShowQrCode,
                icon: const Icon(CupertinoIcons.qrcode),
                label: const Text('Generate QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.darkBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  textStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}