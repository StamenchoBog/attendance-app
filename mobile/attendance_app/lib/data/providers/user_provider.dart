import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
// TODO: Remove this after development
import 'package:attendance_app/data/demo_data/mock_user_data.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  final bool _isMockEnabled = false;
  
  UserProvider() {
    _loadUser();
  }
  
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  
  // Load user from secure storage
  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();
    
    // _currentUser = await _authService.getCurrentUser();

    // TODO: Remove this after development
    if (_isMockEnabled) {
      // For development: decide which mock user to load
      // Can be toggled with a debug menu later
      // _currentUser = MockUsers.getMockStudent();
      _currentUser = MockUsers.getMockStudent();
    } else {
      _currentUser = await _authService.getCurrentUser();
    }
    
    _isLoading = false;
    notifyListeners();
  }

  // TODO: Remove this after development
  void mockLoginAs(String userType) {
    if (userType == 'student') {
      _currentUser = MockUsers.getMockStudent();
    } else {
      _currentUser = MockUsers.getMockProfessor();
    }
    notifyListeners();
  }
  
  // Set user after successful login
  Future<void> setUser(User user) async {
    await _authService.storeUser(user);
    _currentUser = user;
    notifyListeners();
  }
  
  // Clear user data on logout
  Future<void> logout() async {
    await _authService.logout(); // Implement this to clear storage
    _currentUser = null;
    notifyListeners();
  }
}
