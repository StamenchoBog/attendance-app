
import 'package:attendance_app/core/utils/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardStateProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  DateTime get selectedDate => _selectedDate;
  TimeOfDay get selectedTime => _selectedTime;

  DashboardStateProvider() {
    _loadDateTimeFromCache();
  }

  Future<void> _loadDateTimeFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(StorageKeys.cacheTimestamp);
    
    if (timestamp != null) {
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheTime).inHours < 1) {
        final dateString = prefs.getString(StorageKeys.cachedDate);
        final timeString = prefs.getString(StorageKeys.cachedTime);
        
        if (dateString != null && timeString != null) {
          _selectedDate = DateTime.parse(dateString);
          final timeParts = timeString.split(':');
          _selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
          notifyListeners();
        }
      }
    }
  }

  Future<void> _saveDateTimeToCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.cachedDate, _selectedDate.toIso8601String());
    await prefs.setString(StorageKeys.cachedTime, '${_selectedTime.hour}:${_selectedTime.minute}');
    await prefs.setInt(StorageKeys.cacheTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  void updateDate(DateTime newDate) {
    if (_selectedDate != newDate) {
      _selectedDate = newDate;
      _saveDateTimeToCache();
      notifyListeners();
    }
  }

  void updateTime(TimeOfDay newTime) {
    if (_selectedTime != newTime) {
      _selectedTime = newTime;
      _saveDateTimeToCache();
      notifyListeners();
    }
  }
}
