import 'package:attendance_app/data/providers/date_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/core/theme/app_text_styles.dart';
import 'package:attendance_app/core/utils/ui_helpers.dart';
import 'package:attendance_app/core/constants/app_constants.dart';
import 'package:provider/provider.dart';

// Widgets
import 'package:attendance_app/presentation/widgets/static/app_top_bar.dart';
import 'package:attendance_app/presentation/widgets/static/bottom_nav_bar.dart';
import 'package:attendance_app/presentation/widgets/specific/main_dashboard_widgets.dart';
import 'package:attendance_app/presentation/screens/professor_class_details_screen.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';
import 'package:attendance_app/presentation/widgets/static/modern_dropdown.dart';
import 'package:logger/logger.dart';

import '../../data/models/professor.dart';
import '../../data/models/room.dart';
import '../../data/models/subject.dart';
import '../../data/providers/user_provider.dart';
import '../../data/repositories/class_session_repository.dart';
import '../../data/repositories/room_repository.dart';
import '../../data/repositories/subject_repository.dart';
import '../../data/services/service_starter.dart';
import '../widgets/static/dashboard_skeleton.dart';

class ProfessorDashboard extends StatefulWidget {
  const ProfessorDashboard({super.key});

  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  int _selectedIndex = 0;
  final Logger _logger = Logger();
  final ClassSessionRepository _classSessionRepository = locator<ClassSessionRepository>();
  final SubjectRepository _subjectRepository = locator<SubjectRepository>();
  final RoomRepository _roomRepository = locator<RoomRepository>();

  DateProvider? _dateProvider;
  List<dynamic> _allClasses = [];
  List<dynamic> _filteredClasses = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _searchQuery = '';
  List<Subject> _availableSubjects = [];
  List<Map<String, dynamic>> _availableRooms = [];
  Subject? _selectedSubject;
  Map<String, dynamic>? _selectedRoom;

  @override
  void initState() {
    super.initState();
    // Load data immediately when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<DateProvider>(context);
    if (provider != _dateProvider) {
      _dateProvider?.removeListener(_loadInitialData);
      _dateProvider = provider;
      _dateProvider?.addListener(_loadInitialData);
      // Load data when DateProvider changes (for date selection changes)
      // The initial load is already handled in initState
    }
  }

  @override
  void dispose() {
    _dateProvider?.removeListener(_loadInitialData);
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedSubject = null; // Reset filters when date changes
      _selectedRoom = null;
    });

    try {
      final user = Provider.of<UserProvider>(context, listen: false).currentUser as Professor?;
      if (user == null) {
        throw Exception("Professor not logged in");
      }

      // Use date-based endpoint to get classes for the selected date
      final selectedDate = _dateProvider?.selectedDate ?? DateTime.now();
      final classes = await _classSessionRepository.getProfessorClassSessionsByDate(
        professorId: user.id,
        date: selectedDate,
        context: context,
      );

      // Extract unique subjects and rooms from the actual classes for this date
      final Set<String> subjectIds = {};
      final Set<String> roomNames = {};

      for (final classData in classes ?? []) {
        if (classData['subjectId'] != null) {
          subjectIds.add(classData['subjectId'].toString());
        }
        if (classData['roomName'] != null) {
          roomNames.add(classData['roomName'].toString());
        }
      }

      // Get all subjects and rooms
      final allSubjects = await _subjectRepository.getSubjectsByProfessorId(user.id);
      final allRooms = await _roomRepository.getAllRooms();

      // Debug logging
      _logger.d('Classes for date: ${classes?.length ?? 0}');
      _logger.d('Subject IDs from classes: $subjectIds');
      _logger.d('Room names from classes: $roomNames');
      _logger.d('All subjects count: ${allSubjects?.length ?? 0}');
      _logger.d('All rooms count: ${allRooms?.length ?? 0}');

      // For subjects: Show all subjects the professor teaches (not just today's)
      // This ensures the filter always has options
      final availableSubjects = allSubjects ?? [];

      // For rooms: Only show rooms that have classes today (more restrictive)
      final availableRooms = (allRooms ?? []).where((room) => roomNames.contains(room['name'])).toList();

      // Debug the filtered results
      _logger.d('Available subjects after filtering: ${availableSubjects.length}');
      _logger.d('Available rooms after filtering: ${availableRooms.length}');
      if (availableSubjects.isNotEmpty) {
        _logger.d('Subject names: ${availableSubjects.map((s) => s.name).toList()}');
      }
      if (availableRooms.isNotEmpty) {
        _logger.d('Room names: ${availableRooms.map((r) => r['name']).toList()}');
      }

      if (!mounted) return;
      setState(() {
        _availableSubjects = availableSubjects;
        _availableRooms = availableRooms;
        _allClasses = classes ?? [];
        _filteredClasses = classes ?? [];
        _isLoading = false;
      });

      _filterClasses();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to load data.";
        _isLoading = false;
      });
      _logger.e(e);
    }
  }

  void _filterClasses() {
    _logger.d(
      'Filtering classes - Selected Subject: ${_selectedSubject?.name}, Selected Room: ${_selectedRoom?['name']}',
    );

    List<dynamic> filtered = _allClasses;

    // Filter by dropdowns first
    if (_selectedSubject != null) {
      filtered = filtered.where((c) => c['subjectId'].toString() == _selectedSubject!.id).toList();
      _logger.d('After subject filter: ${filtered.length} classes');
    }

    if (_selectedRoom != null) {
      filtered = filtered.where((c) => c['roomName'] == _selectedRoom!['name']).toList();
      _logger.d('After room filter: ${filtered.length} classes');
    }

    // Then filter by search query
    if (_searchQuery.isNotEmpty) {
      final lowerCaseQuery = _searchQuery.toLowerCase();
      filtered =
          filtered.where((classData) {
            final subjectName = (classData['subjectName'] as String? ?? '').toLowerCase();
            final roomName = (classData['roomName'] as String? ?? '').toLowerCase();
            return subjectName.contains(lowerCaseQuery) || roomName.contains(lowerCaseQuery);
          }).toList();
      _logger.d('After search filter: ${filtered.length} classes');
    }

    _logger.d('Final filtered classes count: ${filtered.length}');
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

  @override
  Widget build(BuildContext context) {
    final dateState = Provider.of<DateProvider>(context);

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
                searchHintText: 'Search by subject or room...',
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filterClasses();
                  });
                },
              ),
              UIHelpers.verticalSpace(AppConstants.spacing16),
              buildProfessorInfoCard(context),
              UIHelpers.verticalSpace(AppConstants.spacing16),
              Row(
                children: [
                  buildDateTimeChip(
                    DateFormat('MMM d, yy').format(dateState.selectedDate),
                    CupertinoIcons.calendar,
                    () => _selectDate(context),
                  ),
                  const Spacer(),
                ],
              ),
              UIHelpers.verticalSpace(AppConstants.spacing12),
              Row(
                children: [
                  Expanded(
                    child: ModernDropdown<Subject>(
                      value: _selectedSubject,
                      hint: "Filter by Subject",
                      items: _availableSubjects,
                      getDisplayText: (subject) => subject.name,
                      onChanged: (Subject? newValue) {
                        print('Subject filter changed to: ${newValue?.name ?? "null"}');
                        setState(() {
                          _selectedSubject = newValue;
                        });
                        _filterClasses();
                      },
                      isLoading: _isLoading,
                      prefixIcon: CupertinoIcons.book,
                    ),
                  ),
                  UIHelpers.horizontalSpace(AppConstants.spacing12),
                  Expanded(
                    child: ModernDropdown<Map<String, dynamic>>(
                      value: _selectedRoom,
                      hint: "Filter by Room",
                      items: _availableRooms,
                      getDisplayText: (room) => room['name'],
                      // Adjusted to match the repository return type
                      onChanged: (Map<String, dynamic>? newValue) {
                        setState(() {
                          _selectedRoom = newValue;
                        });
                        _filterClasses();
                      },
                      isLoading: _isLoading,
                      prefixIcon: CupertinoIcons.location,
                    ),
                  ),
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
                              ElevatedButton(onPressed: _loadInitialData, child: const Text('Retry')),
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
                                  'No classes found for the selected criteria.',
                                  style: AppTextStyles.bodyMedium.copyWith(color: ColorPalette.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          itemCount: _filteredClasses.length,
                          itemBuilder: (context, index) {
                            final classData = _filteredClasses[index];
                            final now = DateTime.now();
                            final startTimeString = classData['startTime'] as String?;
                            final endTimeString = classData['endTime'] as String?;
                            bool hasClassStarted = false;

                            if (startTimeString != null && endTimeString != null) {
                              try {
                                final startTime = DateFormat('HH:mm').parse(startTimeString);
                                final endTime = DateFormat('HH:mm').parse(endTimeString);
                                final classStartDateTime = DateTime(
                                  dateState.selectedDate.year,
                                  dateState.selectedDate.month,
                                  dateState.selectedDate.day,
                                  startTime.hour,
                                  startTime.minute,
                                );
                                final classEndDateTime = DateTime(
                                  dateState.selectedDate.year,
                                  dateState.selectedDate.month,
                                  dateState.selectedDate.day,
                                  endTime.hour,
                                  endTime.minute,
                                );
                                hasClassStarted = now.isAfter(classStartDateTime) && now.isBefore(classEndDateTime);
                              } catch (e) {
                                _logger.e("Error parsing time: $e");
                              }
                            }

                            return GestureDetector(
                              onTap: () {
                                fastPush(context, ProfessorClassDetailsScreen(classData: classData));
                              },
                              child: buildClassListItem(
                                classData['subjectName'] ?? 'N/A',
                                classData['roomName'] ?? 'N/A',
                                classData['startTime'] ?? 'N/A',
                                hasClassStarted,
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
