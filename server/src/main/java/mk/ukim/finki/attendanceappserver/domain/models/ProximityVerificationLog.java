package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.*;
import mk.ukim.finki.attendanceappserver.domain.enums.ProximityLevel;
import mk.ukim.finki.attendanceappserver.domain.enums.ProximityVerificationStatus;
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
    private ProximityLevel proximityLevel;

    @Column("estimated_distance")
    private Double estimatedDistance;

    @Column("verification_timestamp")
    private LocalDateTime verificationTimestamp;

    @Column("verification_status")
    private ProximityVerificationStatus verificationStatus;

    @Column("verification_duration_seconds")
    private Integer verificationDurationSeconds;

    @Column("beacon_type")
    private String beaconType;

    @Column("session_token")
    private String sessionToken;
}
