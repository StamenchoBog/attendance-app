package mk.ukim.finki.attendanceappserver.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.Data;

import java.time.LocalDateTime;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProximityDetectionDTO {

    private String studentIndex;
    private String sessionToken;
    private String beaconDeviceId;
    private String detectedRoomId;
    private Integer rssi;
    private String proximityLevel; // NEAR, MEDIUM, FAR, OUT_OF_RANGE
    private Double estimatedDistance;
    private LocalDateTime detectionTimestamp;
    private String beaconType; // DEDICATED, PROFESSOR_PHONE
}
