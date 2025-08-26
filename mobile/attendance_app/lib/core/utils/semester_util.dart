import 'package:intl/intl.dart';

String getCurrentSemester() {
  final now = DateTime.now();
  final year = now.year;
  final month = now.month;

  // Winter semester is from October to January
  // Summer semester is from February to June
  if (month >= 2 && month <= 6) {
    return 'SUMMER_${year - 1}/$year';
  } else {
    return 'WINTER_$year/${year + 1}';
  }
}
