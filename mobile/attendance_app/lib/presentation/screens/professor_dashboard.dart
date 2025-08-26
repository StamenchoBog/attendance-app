import 'package:attendance_app/data/providers/date_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:provider/provider.dart';
// Widgets
import 'package:attendance_app/presentation/widgets/static/app_top_bar.dart';
import 'package:attendance_app/presentation/widgets/static/bottom_nav_bar.dart';
import 'package:attendance_app/presentation/widgets/specific/main_dashboard_widgets.dart';
import 'package:attendance_app/presentation/screens/professor_class_details_screen.dart';
import 'package:attendance_app/presentation/widgets/static/helpers/navigation_helpers.dart';
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
  List<Subject> _subjects = [];
  List<Room> _rooms = [];
  Subject? _selectedSubject;
  Room? _selectedRoom;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<DateProvider>(context);
    if (provider != _dateProvider) {
      _dateProvider?.removeListener(_loadInitialData);
      _dateProvider = provider;
      _dateProvider?.addListener(_loadInitialData);
      // Initial load
      _loadInitialData();
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
    });

    try {
      final user = Provider.of<UserProvider>(context, listen: false).currentUser as Professor?;
      if (user == null) {
        throw Exception("Professor not logged in");
      }
      final subjects = await _subjectRepository.getSubjectsByProfessorId(user.id);
      final rooms = await _roomRepository.getRooms();
      final classes = await _classSessionRepository.getProfessorClassSessions(user.id, _dateProvider!.selectedDate);
      
      if (!mounted) return;
      setState(() {
        _subjects = subjects.toSet().toList();
        _rooms = rooms;
        _allClasses = classes;
        _filteredClasses = classes;
        _isLoading = false;
        _filterClasses();
      });
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
    List<dynamic> filtered = _allClasses;

    // Filter by dropdowns first
    if (_selectedSubject != null) {
      filtered = filtered.where((c) => c['subjectId'] == _selectedSubject!.id).toList();
    }

    if (_selectedRoom != null) {
      filtered = filtered.where((c) => c['roomName'] == _selectedRoom!.name).toList();
    }

    // Then filter by search query
    if (_searchQuery.isNotEmpty) {
      final lowerCaseQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((classData) {
        final subjectName = (classData['subjectName'] as String? ?? '').toLowerCase();
        final roomName = (classData['roomName'] as String? ?? '').toLowerCase();
        return subjectName.contains(lowerCaseQuery) || roomName.contains(lowerCaseQuery);
      }).toList();
    }

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
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
              AppTopBar(
                searchHintText: 'Search by subject or room...',
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filterClasses();
                  });
                },
              ),
              SizedBox(height: 15.h),
              buildProfessorInfoCard(context),
              SizedBox(height: 15.h),
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
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<Subject>(
                      isExpanded: true,
                      value: _selectedSubject,
                      hint: const Text("Filter by Subject"),
                      onChanged: (Subject? newValue) {
                        setState(() {
                          _selectedSubject = newValue;
                        });
                        _filterClasses();
                      },
                      items: _subjects.map<DropdownMenuItem<Subject>>((Subject subject) {
                        return DropdownMenuItem<Subject>(
                          value: subject,
                          child: Text(subject.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: DropdownButton<Room>(
                      isExpanded: true,
                      value: _selectedRoom,
                      hint: const Text("Filter by Room"),
                      onChanged: (Room? newValue) {
                        setState(() {
                          _selectedRoom = newValue;
                        });
                        _filterClasses();
                      },
                      items: _rooms.map<DropdownMenuItem<Room>>((Room room) {
                        return DropdownMenuItem<Room>(
                          value: room,
                          child: Text(room.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: _isLoading
                    ? const DashboardSkeleton()
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.exclamationmark_triangle,
                                  size: 50.sp,
                                  color: ColorPalette.iconGrey,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.h),
                                ElevatedButton(
                                  onPressed: _loadInitialData,
                                  child: const Text('Retry'),
                                ),
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
                                      size: 50.sp,
                                      color: ColorPalette.iconGrey,
                                    ),
                                    SizedBox(height: 16.h),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                                      child: Text(
                                        'No classes found for the selected criteria.',
                                        style: TextStyle(fontSize: 14.sp, color: ColorPalette.textSecondary),
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
                                      final classStartDateTime = DateTime(dateState.selectedDate.year, dateState.selectedDate.month, dateState.selectedDate.day, startTime.hour, startTime.minute);
                                      final classEndDateTime = DateTime(dateState.selectedDate.year, dateState.selectedDate.month, dateState.selectedDate.day, endTime.hour, endTime.minute);
                                      hasClassStarted = now.isAfter(classStartDateTime) && now.isBefore(classEndDateTime);
                                    } catch (e) {
                                      _logger.e("Error parsing time: $e");
                                    }
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProfessorClassDetailsScreen(classData: classData),
                                        ),
                                      );
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
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}