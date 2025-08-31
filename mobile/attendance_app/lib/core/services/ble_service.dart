import '../../data/models/beacon_models.dart';
import '../../data/models/proximity_verification_models.dart';
import '../bluetooth/beacon_scanner.dart';
import '../bluetooth/bluetooth_permission_manager.dart';
import '../bluetooth/proximity_verification_service.dart';

/// Unified BLE Service facade that maintains backward compatibility
/// while providing access to the new modular services
class BleService {
  final BeaconScanner _scanner = BeaconScanner();
  final ProximityVerificationService _verificationService = ProximityVerificationService();

  /// Legacy method - returns formatted proximity data
  Future<String?> getProximity({Duration? timeout}) async {
    return await _verificationService.getQuickProximity(timeout: timeout);
  }

  /// Enhanced beacon detection
  Future<BeaconDetection?> detectBeaconProximity({Duration? timeout}) async {
    return await _scanner.scanForBeacon(timeout: timeout);
  }

  /// Check and request permissions
  Future<PermissionRequestResult> checkAndRequestPermissions() async {
    return await BluetoothPermissionManager.checkAndRequestPermissions();
  }

  /// Start proximity verification workflow
  Future<ProximityVerificationResponse> startVerification({
    required String sessionToken,
    required String studentIndex,
    String? expectedRoomId,
    Duration? duration,
  }) async {
    return await _verificationService.startVerification(
      sessionToken: sessionToken,
      studentIndex: studentIndex,
      expectedRoomId: expectedRoomId,
      duration: duration,
    );
  }

  /// Get verification progress stream
  Stream<ProximityVerificationProgress> get verificationProgress =>
      _verificationService.progress;

  /// Get detection stream
  Stream<BeaconDetection> get detections => _verificationService.detections;

  /// Convert to API format
  List<ProximityDetectionRequest> getApiDetections({
    required String sessionToken,
    required String studentIndex,
  }) {
    return _verificationService.getApiDetections(
      sessionToken: sessionToken,
      studentIndex: studentIndex,
    );
  }

  void dispose() {
    _verificationService.dispose();
  }
}
