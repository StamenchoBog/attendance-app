package mk.ukim.finki.attendanceappserver.domain.enums;

/**
 * Enum representing verification status for proximity-based attendance verification
 */
public enum ProximityVerificationStatus {
    ONGOING,
    SUCCESS,                    // Verification successful with high confidence
    SUCCESS_LOW_CONFIDENCE,     // Verification successful but with lower confidence
    FAILED,                     // Verification failed due to insufficient proximity
    WRONG_ROOM,                // Student detected in wrong classroom
    OUT_OF_RANGE               // Too many out-of-range detections
}
