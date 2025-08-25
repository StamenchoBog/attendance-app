import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/data/models/professor.dart';
import 'package:attendance_app/data/providers/dashboard_state_provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:attendance_app/data/repositories/class_session_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/presentation/widgets/static/app_top_bar.dart';
import 'package:attendance_app/presentation/widgets/static/bottom_nav_bar.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:flutter/foundation.dart';

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

  DashboardStateProvider? _dashboardStateProvider;
  List<dynamic> _classes = [];
  dynamic _selectedClass;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<DashboardStateProvider>(context);
    if (provider != _dashboardStateProvider) {
      _dashboardStateProvider?.removeListener(_loadClassesForDate);
      _dashboardStateProvider = provider;
      _dashboardStateProvider?.addListener(_loadClassesForDate);
      // Initial load
      _loadClassesForDate();
    }
  }

  @override
  void dispose() {
    _dashboardStateProvider?.removeListener(_loadClassesForDate);
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

      final classes = await _classSessionRepository.getProfessorClassSessions(user.id, _dashboardStateProvider!.selectedDate);
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
    final dashboardState = Provider.of<DashboardStateProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dashboardState.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != dashboardState.selectedDate) {
      dashboardState.updateDate(picked);
    }
  }

  Future<void> _generateAndShowQrCode() async {
    if (_selectedClass == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final sessionId = int.parse(_selectedClass['professorClassSessionId']);
      final qrBytes = await _attendanceRepository.generateQrCode(sessionId);
      
      Navigator.of(context).pop(); // Dismiss loading dialog

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            contentPadding: EdgeInsets.all(16.w),
            title: const Text('Scan to Mark Attendance', textAlign: TextAlign.center),
            content: Image.memory(qrBytes),
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
    final dashboardState = Provider.of<DashboardStateProvider>(context);

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
                                DateFormat('MMMM d, yyyy').format(dashboardState.selectedDate),
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