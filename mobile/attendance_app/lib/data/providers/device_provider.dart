import 'package:flutter/material.dart';

class DeviceProvider with ChangeNotifier {
  bool _isDeviceRegistered = false;
  String? _registeredDeviceId;
  bool _isLoading = true;

  bool get isDeviceRegistered => _isDeviceRegistered;

  String? get registeredDeviceId => _registeredDeviceId;

  bool get isLoading => _isLoading;

  void setDeviceRegistrationStatus(bool isRegistered, String? deviceId) {
    _isDeviceRegistered = isRegistered;
    _registeredDeviceId = deviceId;
    _isLoading = false;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
