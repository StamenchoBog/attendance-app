import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Parses a time string in HH:MM or HH:MM:SS format into a TimeOfDay object.
///
/// Ignores seconds if present.
/// Returns null if parsing fails or the format is incorrect.
TimeOfDay? parseHHMM(String timeString) {
  if (timeString.isEmpty) {
    return null;
  }
  try {
    List<String> parts = timeString.split(':');

    // Ensure we have at least two parts (hour and minute)
    if (parts.length >= 2) {
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      // Basic validation for hour and minute ranges
      if (hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      } else {
        // Optional: Log invalid range if needed, or just let it return null
        // print('Hour or minute out of valid range: H=$hour, M=$minute');
        return null; // Explicitly return null for out-of-range values
      }
    } else {
      // Optional: Log invalid format if needed
      // print('Invalid time string format: expected at least HH:MM');
      return null; // Not enough parts for HH:MM
    }
  } catch (e) {
    // Handle parsing errors, e.g., if parts are not integers
    // In a production app, you might use a more sophisticated logger
    // For a util function, printing or re-throwing are options,
    // but returning null is often preferred for parse functions.
    // Consider the context where this util will be used.
    // print('Error parsing time string "$timeString": $e');
    return null; // Return null on any exception during parsing
  }
}

String formatTimeOfDayWithPattern(TimeOfDay timeOfDay, String pattern, {DateTime? referenceDate}) {
  // Use the provided referenceDate or default to a common base date (e.g., today or a fixed date).
  // The date part is only relevant if your pattern accidentally includes date placeholders.
  // For time-only patterns, any date will do.
  final DateTime dateToUse = referenceDate ?? DateTime.now();
  
  final DateTime dateTime = DateTime(
    dateToUse.year,
    dateToUse.month,
    dateToUse.day,
    timeOfDay.hour,
    timeOfDay.minute,
  );
  
  final DateFormat formatter = DateFormat(pattern);
  return formatter.format(dateTime);
}
