import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:attendance_app/core/theme/color_palette.dart';
import 'package:intl/intl.dart';

class CustomDateTimePicker {
  static Future<DateTime?> showDatePicker(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? title,
  }) async {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _DatePickerBottomSheet(
            initialDate: initialDate,
            firstDate: firstDate ?? DateTime(DateTime.now().year - 2),
            lastDate: lastDate ?? DateTime(DateTime.now().year + 2),
            title: title ?? 'Select Date',
          ),
    );
  }

  static Future<TimeOfDay?> showTimePicker(
    BuildContext context, {
    required TimeOfDay initialTime,
    String? title,
    bool use24HourFormat = true,
  }) async {
    return showModalBottomSheet<TimeOfDay>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _TimePickerBottomSheet(
            initialTime: initialTime,
            title: title ?? 'Select Time',
            use24HourFormat: use24HourFormat,
          ),
    );
  }

  static Future<DateTime?> showDateTimePicker(
    BuildContext context, {
    required DateTime initialDateTime,
    DateTime? firstDate,
    DateTime? lastDate,
    String? title,
    bool use24HourFormat = true,
  }) async {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _DateTimePickerBottomSheet(
            initialDateTime: initialDateTime,
            firstDate: firstDate ?? DateTime(DateTime.now().year - 2),
            lastDate: lastDate ?? DateTime(DateTime.now().year + 2),
            title: title ?? 'Select Date & Time',
            use24HourFormat: use24HourFormat,
          ),
    );
  }
}

class _DatePickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;

  const _DatePickerBottomSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.title,
  });

  @override
  State<_DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<_DatePickerBottomSheet> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)),
            ),

            // Title
            Text(
              widget.title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: ColorPalette.textPrimary),
            ),

            SizedBox(height: 20.h),

            // Quick date selection buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickDateButton(
                    label: 'Today',
                    date: DateTime.now(),
                    isSelected: _isSameDay(selectedDate, DateTime.now()),
                    onTap: () => setState(() => selectedDate = DateTime.now()),
                  ),
                  _QuickDateButton(
                    label: 'Tomorrow',
                    date: DateTime.now().add(const Duration(days: 1)),
                    isSelected: _isSameDay(selectedDate, DateTime.now().add(const Duration(days: 1))),
                    onTap: () => setState(() => selectedDate = DateTime.now().add(const Duration(days: 1))),
                  ),
                  _QuickDateButton(
                    label: 'Yesterday',
                    date: DateTime.now().subtract(const Duration(days: 1)),
                    isSelected: _isSameDay(selectedDate, DateTime.now().subtract(const Duration(days: 1))),
                    onTap: () => setState(() => selectedDate = DateTime.now().subtract(const Duration(days: 1))),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Calendar
            Container(
              height: 350.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CalendarDatePicker(
                initialDate: selectedDate,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                onDateChanged: (date) => setState(() => selectedDate = date),
              ),
            ),

            // Action buttons
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorPalette.darkBlue),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: ColorPalette.darkBlue, fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(selectedDate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.darkBlue,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text(
                        'Select',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _QuickDateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickDateButton({required this.label, required this.date, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.darkBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isSelected ? ColorPalette.darkBlue : Colors.grey.shade300),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : ColorPalette.textSecondary,
              ),
            ),
            Text(
              DateFormat('MMM d').format(date),
              style: TextStyle(fontSize: 10.sp, color: isSelected ? Colors.white : ColorPalette.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimePickerBottomSheet extends StatefulWidget {
  final TimeOfDay initialTime;
  final String title;
  final bool use24HourFormat;

  const _TimePickerBottomSheet({required this.initialTime, required this.title, required this.use24HourFormat});

  @override
  State<_TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<_TimePickerBottomSheet> {
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
  }

  void _updateHour(int hour) {
    setState(() {
      selectedTime = TimeOfDay(hour: hour, minute: selectedTime.minute);
    });
  }

  void _updateMinute(int minute) {
    setState(() {
      selectedTime = TimeOfDay(hour: selectedTime.hour, minute: minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)),
            ),

            // Title
            Text(
              widget.title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: ColorPalette.textPrimary),
            ),

            SizedBox(height: 24.h),

            // Current selected time display
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
              decoration: BoxDecoration(
                color: ColorPalette.darkBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: ColorPalette.darkBlue.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Selected Time',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: ColorPalette.textSecondary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.use24HourFormat
                        ? '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}'
                        : selectedTime.format(context),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      color: ColorPalette.darkBlue,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Now button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => selectedTime = TimeOfDay.now()),
                  icon: Icon(Icons.access_time, size: 20.sp, color: ColorPalette.darkBlue),
                  label: Text(
                    'Use Current Time',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: ColorPalette.darkBlue),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ColorPalette.darkBlue, width: 1.5),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Hour and Minute selectors
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  // Hour selector
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Hour',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: ColorPalette.textPrimary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Column(
                          children: [
                            _TimeAdjustButton(
                              icon: Icons.keyboard_arrow_up,
                              onTap: () {
                                int newHour = selectedTime.hour + 1;
                                if (newHour > 23) newHour = 0;
                                _updateHour(newHour);
                              },
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              width: 80.w,
                              height: 60.h,
                              decoration: BoxDecoration(
                                color: ColorPalette.darkBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: ColorPalette.darkBlue.withValues(alpha: 0.3), width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  selectedTime.hour.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w700,
                                    color: ColorPalette.darkBlue,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _TimeAdjustButton(
                              icon: Icons.keyboard_arrow_down,
                              onTap: () {
                                int newHour = selectedTime.hour - 1;
                                if (newHour < 0) newHour = 23;
                                _updateHour(newHour);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Colon separator
                  Padding(
                    padding: EdgeInsets.only(top: 40.h),
                    child: Text(
                      ':',
                      style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w700, color: ColorPalette.darkBlue),
                    ),
                  ),

                  // Minute selector
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Minute',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: ColorPalette.textPrimary,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Column(
                          children: [
                            _TimeAdjustButton(
                              icon: Icons.keyboard_arrow_up,
                              onTap: () {
                                int newMinute = selectedTime.minute + 5;
                                if (newMinute > 59) newMinute = 0;
                                _updateMinute(newMinute);
                              },
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              width: 80.w,
                              height: 60.h,
                              decoration: BoxDecoration(
                                color: ColorPalette.darkBlue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: ColorPalette.darkBlue.withValues(alpha: 0.3), width: 1.5),
                              ),
                              child: Center(
                                child: Text(
                                  selectedTime.minute.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w700,
                                    color: ColorPalette.darkBlue,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            _TimeAdjustButton(
                              icon: Icons.keyboard_arrow_down,
                              onTap: () {
                                int newMinute = selectedTime.minute - 5;
                                if (newMinute < 0) newMinute = 55;
                                _updateMinute(newMinute);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Action buttons
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(selectedTime),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.darkBlue,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 2,
                      ),
                      child: Text(
                        'Select',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickTimeButton({required this.label, required this.time, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? ColorPalette.darkBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isSelected ? ColorPalette.darkBlue : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : ColorPalette.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TimeAdjustButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TimeAdjustButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: ColorPalette.darkBlue,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(color: ColorPalette.darkBlue.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }
}

class _DateTimePickerBottomSheet extends StatefulWidget {
  final DateTime initialDateTime;
  final DateTime firstDate;
  final DateTime lastDate;
  final String title;
  final bool use24HourFormat;

  const _DateTimePickerBottomSheet({
    required this.initialDateTime,
    required this.firstDate,
    required this.lastDate,
    required this.title,
    required this.use24HourFormat,
  });

  @override
  State<_DateTimePickerBottomSheet> createState() => _DateTimePickerBottomSheetState();
}

class _DateTimePickerBottomSheetState extends State<_DateTimePickerBottomSheet> {
  late DateTime selectedDateTime;

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.initialDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r)),
            ),

            // Title
            Text(
              widget.title,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: ColorPalette.textPrimary),
            ),

            SizedBox(height: 20.h),

            // DateTime picker
            Container(
              height: 300.h,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                use24hFormat: widget.use24HourFormat,
                initialDateTime: selectedDateTime,
                minimumDate: widget.firstDate,
                maximumDate: widget.lastDate,
                onDateTimeChanged: (DateTime dateTime) {
                  setState(() {
                    selectedDateTime = dateTime;
                  });
                },
              ),
            ),

            // Action buttons
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: ColorPalette.darkBlue),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: ColorPalette.darkBlue, fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(selectedDateTime),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.darkBlue,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: Text(
                        'Select',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
