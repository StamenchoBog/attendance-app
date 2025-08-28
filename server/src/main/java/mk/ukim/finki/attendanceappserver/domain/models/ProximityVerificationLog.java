package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.*;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;

@Data
@Builder(toBuilder = true)
@Table(name = "proximity_verification_log")
public class ProximityVerificationLog {

    @Id
    @Column("id")
    private Long id;

    @Column("student_attendance_id")
    private Integer studentAttendanceId;

    @Column("student_index")
    private String studentIndex;

    @Column("beacon_device_id")
    private String beaconDeviceId;

    @Column("detected_room_id")
    private String detectedRoomId;

    @Column("expected_room_id")
    private String expectedRoomId;

    @Column("rssi")
    private Integer rssi;

    @Column("proximity_level")
    private String proximityLevel; // NEAR, MEDIUM, FAR, OUT_OF_RANGE

    @Column("estimated_distance")
    private Double estimatedDistance;

    @Column("verification_timestamp")
    private LocalDateTime verificationTimestamp;

    @Column("verification_status")
    private String verificationStatus; // ONGOING, SUCCESS, FAILED, TIMEOUT

    @Column("verification_duration_seconds")
    private Integer verificationDurationSeconds;

    @Column("beacon_type")
    private String beaconType; // DEDICATED_BEACON, PROFESSOR_PHONE

    @Column("session_token")
    private String sessionToken;
}
