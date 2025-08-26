import 'package:attendance_app/core/utils/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  DateProvider() {
    _loadDateFromCache();
  }

  Future<void> _loadDateFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(StorageKeys.cacheTimestamp);
    
    if (timestamp != null) {
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheTime).inHours < 1) {
        final dateString = prefs.getString(StorageKeys.cachedDate);
        
        if (dateString != null) {
          _selectedDate = DateTime.parse(dateString);
          notifyListeners();
        }
      }
    }
  }

  Future<void> _saveDateToCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.cachedDate, _selectedDate.toIso8601String());
    await prefs.setInt(StorageKeys.cacheTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  void updateDate(DateTime newDate) {
    if (_selectedDate.year != newDate.year || _selectedDate.month != newDate.month || _selectedDate.day != newDate.day) {
      _selectedDate = newDate;
      _saveDateToCache();
      notifyListeners();
    }
  }
}
