package mk.ukim.finki.attendanceappserver.domain.enums;

/**
 * Enum representing different proximity levels for BLE beacon detection
 * Based on RSSI values from mobile app proximity calculation
 */
public enum ProximityLevel {
    NEAR,           // < 2 meters (RSSI > -45)
    MEDIUM,         // 2-15 meters (RSSI > -65)
    FAR,            // 15-30 meters (RSSI > -80)
    OUT_OF_RANGE    // > 30 meters (RSSI <= -80)
}
