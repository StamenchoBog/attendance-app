package mk.ukim.finki.attendanceappserver.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AttendanceRegistrationRequestDTO {

    private String studentIndex;
    private int professorClassSessionId;
    private String proximity;
    private LocalDateTime registrationTime;
    private String deviceId;

    // ? private String GPSLocation;
}
