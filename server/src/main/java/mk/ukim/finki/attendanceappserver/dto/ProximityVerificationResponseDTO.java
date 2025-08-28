package mk.ukim.finki.attendanceappserver.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProximityVerificationResponseDTO {

    private Boolean verificationSuccess;
    private String verificationStatus; // SUCCESS, FAILED, TIMEOUT, WRONG_ROOM
    private String detectedRoomId;
    private String expectedRoomId;
    private Double averageDistance;
    private Integer totalDetections;
    private Integer validDetections;
    private LocalDateTime verificationStartTime;
    private LocalDateTime verificationEndTime;
    private Integer actualDurationSeconds;
    private String failureReason;
}
