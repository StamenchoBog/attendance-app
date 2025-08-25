import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleService {
  final String finkiBeaconServiceUuid = "A07498CA-AD5B-474E-940D-16F1F759427C";

  Future<String> getProximity() async {
    final completer = Completer<String>();
    StreamSubscription? scanSubscription;

    // Set a timeout for the scan
    final scanTimeout = Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        scanSubscription?.cancel();
        completer.completeError('Beacon not found in time.');
      }
    });

    // Start scanning
    scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.advertisementData.serviceUuids.contains(Guid(finkiBeaconServiceUuid))) {
          if (!completer.isCompleted) {
            scanSubscription?.cancel();
            scanTimeout.cancel();
            final proximity = _rssiToProximity(r.rssi);
            completer.complete(proximity);
            break;
          }
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    return completer.future;
  }

  String _rssiToProximity(int rssi) {
    if (rssi > -70) {
      return "NEAR";
    } else if (rssi > -85) {
      return "MEDIUM";
    } else {
      return "FAR";
    }
  }
}
