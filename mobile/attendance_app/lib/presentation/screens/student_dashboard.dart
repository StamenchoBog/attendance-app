import 'package:attendance_app/core/services/device_identifier_service.dart';
import 'package:attendance_app/core/utils/error_message_helper.dart';
import 'package:attendance_app/core/utils/notification_helper.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:attendance_app/data/models/student.dart';
import 'package:attendance_app/data/providers/date_provider.dart';
import 'package:attendance_app/data/providers/time_provider.dart';
import 'package:attendance_app/presentation/screens/qr_scanner_screen.dart';
import 'package:attendance_app/presentation/widgets/specific/class_details_bottom_sheet.dart';
import 'package:attendance_app/presentation/widgets/dialogs/first_time_device_registration_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:provider/provider.dart';
import 'package:attendance_app/data/providers/user_provider.dart';
import 'package:logger/logger.dart';

// Widgets
import 'package:attendance_app/presentation/widgets/static/app_top_bar.dart';
import 'package:attendance_app/presentation/widgets/static/bottom_nav_bar.dart';
import 'package:attendance_app/presentation/widgets/specific/main_dashboard_widgets.dart';

// Repositories
import 'package:attendance_app/data/repositories/class_session_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:attendance_app/presentation/widgets/static/dashboard_skeleton.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';
import 'package:attendance_app/data/providers/device_provider.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  static final Logger _logger = Logger();

  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> _allClasses = [];
  List<dynamic> _filteredClasses = [];
  String _searchQuery = '';

  final ClassSessionRepository _classSessionRepository = locator<ClassSessionRepository>();
  final DeviceIdentifierService _deviceIdentifierService = DeviceIdentifierService();
  DateProvider? _dateProvider;
  TimeProvider? _timeProvider;
  DeviceProvider? _deviceProvider;

  @override
  void initState() {
    super.initState();
    // Check for device registration after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeviceRegistration();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dateProvider = Provider.of<DateProvider>(context);
    final timeProvider = Provider.of<TimeProvider>(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);

    if (dateProvider != _dateProvider || timeProvider != _timeProvider || deviceProvider != _deviceProvider) {
      _dateProvider?.removeListener(_loadClasses);
      _timeProvider?.removeListener(_loadClasses);

      _dateProvider = dateProvider;
      _timeProvider = timeProvider;
      _deviceProvider = deviceProvider;

      _dateProvider?.addListener(_loadClasses);
      _timeProvider?.addListener(_loadClasses);

      // Initial load
      _loadClasses();
    }
  }

  @override
  void dispose() {
    _dateProvider?.removeListener(_loadClasses);
    _timeProvider?.removeListener(_loadClasses);
    super.dispose();
  }

  Future<void> _loadClasses() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final classes = await _getClasses();
      if (!mounted) return;
      setState(() {
        _allClasses = classes;
        _filteredClasses = classes;
        _isLoading = false;
        _filterClasses();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load classes. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _filterClasses() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredClasses = _allClasses;
      });
      return;
    }

    final lowerCaseQuery = _searchQuery.toLowerCase();
    final filtered =
        _allClasses.where((classData) {
          final subjectName = (classData['subjectName'] as String? ?? '').toLowerCase();
          final roomName = (classData['classRoomName'] as String? ?? '').toLowerCase();
          final professorName = (classData['professorName'] as String? ?? '').toLowerCase();

          return subjectName.contains(lowerCaseQuery) ||
              roomName.contains(lowerCaseQuery) ||
              professorName.contains(lowerCaseQuery);
        }).toList();

    setState(() {
      _filteredClasses = filtered;
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      handleBottomNavigation(context, index);
    }
  }

  void _onClassTapped(Map<String, dynamic> classData, bool hasPassed) async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser as Student?;
    if (user == null) return;

    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    if (deviceProvider.isLoading) {
      return;
    }

    if (!deviceProvider.isDeviceRegistered) {
      _checkDeviceRegistration();
      return;
    }

    final deviceId = await _deviceIdentifierService.getPlatformSpecificIdentifier();
    if (deviceId == null || deviceId != deviceProvider.registeredDeviceId) {
      if (mounted) {
        NotificationHelper.showError(
          context,
          'This device is not registered for attendance. Please use your registered device or request a device change.',
        );
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      builder:
          (context) => ClassDetailsBottomSheet(
            classData: classData,
            hasPassed: hasPassed,
            onVerifyAttendance: () {
              Navigator.of(context).pop();
              fastPush(context, QrScannerScreen(studentIndex: user.studentIndex, deviceId: deviceId));
            },
          ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateProvider.selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ColorPalette.darkBlue,
              onPrimary: Colors.white,
              onSurface: ColorPalette.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: ColorPalette.darkBlue)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != dateProvider.selectedDate) {
      dateProvider.updateDate(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: timeProvider.selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null && picked != timeProvider.selectedTime) {
      timeProvider.updateTime(picked);
    }
  }

  Future<List<dynamic>> _getClasses() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final timeProvider = Provider.of<TimeProvider>(context, listen: false);

    final user = userProvider.currentUser;
    if (user == null || user is! Student) {
      _logger.e('No student found or user is not a student');
      return [];
    }

    final student = user;
    final studentIndex = student.studentIndex;

    final selectedDateTime = DateTime(
      dateProvider.selectedDate.year,
      dateProvider.selectedDate.month,
      dateProvider.selectedDate.day,
      timeProvider.selectedTime.hour,
      timeProvider.selectedTime.minute,
    );

    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
    final formattedDateTime = dateFormatter.format(selectedDateTime);

    final classes = await _classSessionRepository.getClassSessionsByStudentIndexForGivenDateAndTime(
      studentIndex: studentIndex,
      dateTime: formattedDateTime,
      context: context,
    );

    // API returns ClassSessionOverview objects which are already Maps
    return classes ?? [];
  }

  Future<void> _checkDeviceRegistration() async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
    if (user == null || user is! Student) return;

    deviceProvider.setLoading(true);

    try {
      // Check if user has a registered device
      final registeredDevice = await _deviceIdentifierService.getRegisteredDevice(user.studentIndex);

      final isRegistered = registeredDevice['id'] != null;
      deviceProvider.setDeviceRegistrationStatus(isRegistered, registeredDevice['id']);

      // If no registered device, show first-time registration dialog
      if (!isRegistered) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (context) => FirstTimeDeviceRegistrationDialog(
                  studentIndex: user.studentIndex,
                  onSuccess: () {
                    Navigator.of(context).pop();
                    _logger.i('Device registration completed successfully');
                    // Re-check registration status to update the provider
                    _checkDeviceRegistration();
                  },
                  onCancel: () {
                    Navigator.of(context).pop();
                    _logger.i('Device registration cancelled by user');
                  },
                ),
          );
        }
        return;
      }

      _logger.i('Student ${user.studentIndex} has a registered device: ${registeredDevice['id']}');
    } catch (e) {
      deviceProvider.setLoading(false);
      _logger.e("Error checking device registration on startup: $e");

      String errorMessage = 'Error checking device registration. Please try again.';
      bool isRetryable = true;

      if (e is DeviceRegistrationException) {
        errorMessage = ErrorMessageHelper.getDeviceRegistrationErrorMessage(e.errorCode, e.message);
        isRetryable = ErrorMessageHelper.isRetryableError(e.errorCode);
      }

      if (mounted) {
        NotificationHelper.showError(
          context,
          errorMessage,
          actionLabel: isRetryable ? 'Retry' : null,
          onAction: isRetryable ? _checkDeviceRegistration : null,
        );
      }
    } finally {
      deviceProvider.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateState = Provider.of<DateProvider>(context);
    final timeState = Provider.of<TimeProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UIHelpers.verticalSpace(AppConstants.spacing16),

              AppTopBar(
                searchHintText: 'Search by subject, room, professor...',
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filterClasses();
                  });
                },
              ),

              UIHelpers.verticalSpace(AppConstants.spacing16),

              buildStudentInfoCard(context),

              UIHelpers.verticalSpace(AppConstants.spacing16),

              Row(
                children: [
                  buildDateTimeChip(
                    DateFormat('MMM d, yy').format(dateState.selectedDate),
                    CupertinoIcons.calendar,
                    () => _selectDate(context),
                  ),
                  UIHelpers.horizontalSpace(AppConstants.spacing16),
                  buildDateTimeChip(
                    DateFormat('HH:mm').format(
                      DateTime(
                        dateState.selectedDate.year,
                        dateState.selectedDate.month,
                        dateState.selectedDate.day,
                        timeState.selectedTime.hour,
                        timeState.selectedTime.minute,
                      ),
                    ),
                    CupertinoIcons.clock,
                    () => _selectTime(context),
                  ),
                  const Spacer(),
                ],
              ),

              UIHelpers.verticalSpace(AppConstants.spacing12),

              Expanded(
                child:
                    _isLoading
                        ? const DashboardSkeleton()
                        : _errorMessage != null
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.exclamationmark_triangle,
                                size: AppConstants.iconSizeXLarge,
                                color: ColorPalette.iconGrey,
                              ),
                              UIHelpers.verticalSpaceMedium,
                              Text(
                                _errorMessage!,
                                style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                              UIHelpers.verticalSpaceMedium,
                              ElevatedButton(onPressed: _loadClasses, child: Text('Retry')),
                            ],
                          ),
                        )
                        : _filteredClasses.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.search_circle,
                                size: AppConstants.iconSizeXLarge,
                                color: ColorPalette.iconGrey,
                              ),
                              UIHelpers.verticalSpaceMedium,
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? 'No classes scheduled for the selected time/date.'
                                      : 'No classes found for "$_searchQuery".',
                                  style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.only(top: AppConstants.spacing8),
                          itemCount: _filteredClasses.length,
                          itemBuilder: (context, index) {
                            final classData = _filteredClasses[index];
                            final now = DateTime.now();
                            final startTimeString = classData['classStartTime'] as String?;
                            final endTimeString = classData['classEndTime'] as String?;
                            bool isOngoing = false;
                            bool hasPassed = false;

                            if (startTimeString != null && endTimeString != null) {
                              try {
                                final startParts = startTimeString.split(':');
                                final endParts = endTimeString.split(':');

                                // For determining if class has passed, we need to compare with the actual class date
                                // Get the class date from the selected date (since that's what we fetched)
                                final dateProvider = Provider.of<DateProvider>(context, listen: false);
                                final classDate = dateProvider.selectedDate;

                                final classStartDateTime = DateTime(
                                  classDate.year,
                                  classDate.month,
                                  classDate.day,
                                  int.parse(startParts[0]),
                                  int.parse(startParts[1]),
                                );
                                final classEndDateTime = DateTime(
                                  classDate.year,
                                  classDate.month,
                                  classDate.day,
                                  int.parse(endParts[0]),
                                  int.parse(endParts[1]),
                                );

                                // Check if class is currently ongoing (only for today's classes)
                                final isToday =
                                    classDate.year == now.year &&
                                    classDate.month == now.month &&
                                    classDate.day == now.day;

                                if (isToday) {
                                  isOngoing = now.isAfter(classStartDateTime) && now.isBefore(classEndDateTime);
                                }

                                // Check if class has passed (ended) - this should make it read-only
                                hasPassed = now.isAfter(classEndDateTime);
                              } catch (e) {
                                _logger.e("Error parsing class time: $e");
                              }
                            }

                            return GestureDetector(
                              onTap: () => _onClassTapped(classData, hasPassed), // Pass hasPassed to the tap handler
                              child: buildClassListItem(
                                classData['subjectName'] ?? 'N/A',
                                classData['classRoomName'] ?? 'N/A',
                                classData['classStartTime'] ?? 'N/A',
                                isOngoing,
                                attendanceStatus: classData['attendanceStatus'],
                                isReadOnly: hasPassed, // Pass the read-only status
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(selectedIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
