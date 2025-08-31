package mk.ukim.finki.attendanceappserver.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProximityVerificationRequestDTO {

    private String studentIndex;
    private String sessionToken;
    private Integer attendanceId;
    private String expectedRoomId;
    private Integer verificationDurationSeconds; // 10, 20, or 30 seconds
    private List<ProximityDetectionDTO> proximityDetections; // Multiple readings during verification
}
