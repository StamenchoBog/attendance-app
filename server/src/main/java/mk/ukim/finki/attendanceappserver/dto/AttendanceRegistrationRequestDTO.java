package mk.ukim.finki.attendanceappserver.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AttendanceRegistrationRequestDTO {

    private String token;
    private String studentIndex;
    private String deviceId; // Add device verification
}
