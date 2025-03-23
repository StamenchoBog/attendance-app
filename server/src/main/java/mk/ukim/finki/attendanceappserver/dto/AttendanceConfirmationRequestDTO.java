package mk.ukim.finki.attendanceappserver.dto;


import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AttendanceConfirmationRequestDTO {

    private String studentId;
    private String scheduledClassSessionId;
    private String proximity;
}
