package mk.ukim.finki.attendanceappserver.dto;


import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AttendanceConfirmationRequestDTO {

    private int attendanceId;
    private String proximity;
}
