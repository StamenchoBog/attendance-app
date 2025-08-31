package mk.ukim.finki.attendanceappserver.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.util.List;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AttendanceRegistrationRequestDTO {

    private String token;
    private String studentIndex;
    private String deviceId;
    private List<ProximityDetectionDTO> proximityDetections;
    private String expectedRoomId;
    private Integer verificationDurationSeconds;
}
