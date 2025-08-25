import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/core/theme/color_palette.dart';

class HorizontalDayScroller extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const HorizontalDayScroller({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<HorizontalDayScroller> createState() => _HorizontalDayScrollerState();
}

class _HorizontalDayScrollerState extends State<HorizontalDayScroller> {
  late ScrollController _scrollController;
  late DateTime _firstDay;
  final Map<int, double> _dayOffsets = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _firstDay = DateTime.now().subtract(const Duration(days: 1));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jumpToDate(widget.selectedDate);
    });
  }

  @override
  void didUpdateWidget(HorizontalDayScroller oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      // Use a post-frame callback to ensure the layout is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jumpToDate(widget.selectedDate);
      });
    }
  }

  void _jumpToDate(DateTime date) {
    final dayIndex = date.difference(_firstDay).inDays;
    final offset = _dayOffsets[dayIndex];
    if (offset != null && _scrollController.hasClients) {
      _scrollController.animateTo(
        offset - (context.size!.width / 2) + 30.w, // Center the selected day
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65.h, // Fixed height for the scroller
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 60, // Show 60 days
        itemBuilder: (context, index) {
          final date = _firstDay.add(Duration(days: index));
          final isSelected = date.year == widget.selectedDate.year &&
                             date.month == widget.selectedDate.month &&
                             date.day == widget.selectedDate.day;
          final isToday = date.year == DateTime.now().year &&
                          date.month == DateTime.now().month &&
                          date.day == DateTime.now().day;

          final bool showMonth;
          if (index == 0) {
            showMonth = true;
          } else {
            final prevDate = _firstDay.add(Duration(days: index - 1));
            showMonth = date.month != prevDate.month;
          }

          // Calculate and store the offset of each day widget
          double offset = index * 65.w; // Approximate width of each item
          _dayOffsets[index] = offset;

          return Row(
            children: [
              if (showMonth)
                Padding(
                  padding: EdgeInsets.only(left: 8.w, right: 8.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.MMM(null).format(date),
                        style: TextStyle(fontSize: 12.sp, color: ColorPalette.darkBlue, fontWeight: FontWeight.bold),
                      ),
                      Container(height: 10.h, width: 1.w, color: ColorPalette.placeholderGrey),
                    ],
                  ),
                ),
              GestureDetector(
                onTap: () => widget.onDateSelected(date),
                child: Container(
                  width: 55.w,
                  margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isSelected ? ColorPalette.darkBlue : ColorPalette.lightestBlue,
                    borderRadius: BorderRadius.circular(12.r),
                    border: isToday && !isSelected ? Border.all(color: ColorPalette.darkBlue, width: 1.5.w) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.E(null).format(date), // Short day name (e.g., Mon)
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : ColorPalette.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : (isToday ? ColorPalette.darkBlue : ColorPalette.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
