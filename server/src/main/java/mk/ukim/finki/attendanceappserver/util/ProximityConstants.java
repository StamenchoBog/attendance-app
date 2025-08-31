package mk.ukim.finki.attendanceappserver.util;

/**
 * Utility class containing proximity analysis constants and thresholds
 * Centralized location for easy configuration changes
 */
public final class ProximityConstants {

    private ProximityConstants() {
        // Utility class - prevent instantiation
    }

    // Proximity verification thresholds
    public static final double PROXIMITY_SUCCESS_THRESHOLD = 0.7; // 70% of detections must be valid
    public static final double OUT_OF_RANGE_THRESHOLD = 0.3; // Max 30% out-of-range detections allowed
    public static final double IDEAL_RATIO_THRESHOLD = 0.5; // 50% threshold for high confidence verification

    // Distance thresholds (in meters) - matching mobile app proximity levels
    public static final double MAX_DISTANCE_THRESHOLD = 30.0; // Maximum distance for any verification
    public static final double IDEAL_DISTANCE_THRESHOLD = 15.0; // Distance limit for MEDIUM range

    // Verification duration limits (in seconds)
    public static final int MIN_VERIFICATION_DURATION = 10;
    public static final int MAX_VERIFICATION_DURATION = 60;

    // RSSI thresholds for proximity levels (matching mobile app)
    public static final int NEAR_RSSI_THRESHOLD = -45;     // RSSI > -45 = NEAR (< 2m)
    public static final int MEDIUM_RSSI_THRESHOLD = -65;   // RSSI > -65 = MEDIUM (2-15m)
    public static final int FAR_RSSI_THRESHOLD = -80;      // RSSI > -80 = FAR (15-30m)
    // RSSI <= -80 = OUT_OF_RANGE (> 30m)
}
