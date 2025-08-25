import 'dart:convert';
import 'dart:typed_data';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:attendance_app/data/models/student_attendance.dart';
import 'package:attendance_app/data/repositories/attendance_repository.dart';
import 'package:attendance_app/data/services/service_starter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfessorClassDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> classData;
  
  const ProfessorClassDetailsScreen({super.key, required this.classData});

  @override
  State<ProfessorClassDetailsScreen> createState() =>
      _ProfessorClassDetailsScreenState();
}

class _ProfessorClassDetailsScreenState
    extends State<ProfessorClassDetailsScreen> {
  final AttendanceRepository _attendanceRepository =
      locator<AttendanceRepository>();
  final Logger _logger = Logger();
  List<StudentAttendance> _attendanceList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }
 
  Future<void> _loadAttendance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final sessionId = int.parse(widget.classData['professorClassSessionId']);
      final attendance =
          await _attendanceRepository.getStudentAttendanceForSession(sessionId);
      setState(() {
        _attendanceList = attendance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load attendance data.";
        _isLoading = false;
      });
      _logger.e(e);
    }
  }

  Future<void> _generateAndShowQrCode() async {
    final classDateTime = DateTime.parse(widget.classData['date']);
    final isPastClass = classDateTime.isBefore(DateTime.now().subtract(const Duration(days: 1)));

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
      final sessionId = int.parse(widget.classData['professorClassSessionId']);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classData['subjectName'] ?? 'Class Details'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildClassInfoCard(),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: _generateAndShowQrCode,
              icon: const Icon(CupertinoIcons.qrcode),
              label: const Text('Generate QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.darkBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Student Attendance',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: _buildAttendanceList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(CupertinoIcons.book_fill, widget.classData['subjectName'] ?? 'N/A'),
            SizedBox(height: 8.h),
            _buildInfoRow(CupertinoIcons.location_solid, widget.classData['roomName'] ?? 'N/A'),
            SizedBox(height: 8.h),
            _buildInfoRow(CupertinoIcons.time_solid, '${widget.classData['startTime']} - ${widget.classData['endTime']}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: ColorPalette.darkBlue, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: _loadAttendance,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    if (_attendanceList.isEmpty) {
      return const Center(child: Text('No students have checked in yet.'));
    }

    return ListView.builder(
      itemCount: _attendanceList.length,
      itemBuilder: (context, index) {
        final attendance = _attendanceList[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4.h),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(attendance.status.toString()),
              child: Icon(_getStatusIcon(attendance.status.toString()), color: Colors.white),
            ),
            title: Text(attendance.studentName ?? 'Unknown Student'),
            subtitle: Text(
              '${attendance.studentIndex} - ${attendance.studyProgramCode}\nArrival: ${DateFormat('HH:mm:ss').format(attendance.studentArrivalTime!)}',
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PRESENT':
        return Colors.green;
      case 'ABSENT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PRESENT':
        return CupertinoIcons.check_mark;
      case 'ABSENT':
        return CupertinoIcons.xmark;
      default:
        return CupertinoIcons.question;
    }
  }
}
