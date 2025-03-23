package mk.ukim.finki.attendanceappserver.dto.db;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@JsonInclude(JsonInclude.Include.NON_NULL)
public class CustomStudentAttendance {

    private String studentAttendanceId;
    private String studentIndex;
    // Professor information
    private String professorId;
    private String professorName;
    // Class Session information
    private String professorClassSessionId;
    private String scheduledClassSessionId;
    // Course information
    private String courseId;
    private LocalDate classDate;
    private String classType;
    private String classRoomName;
    // Class session information
    private LocalTime classStartTime;
    private LocalTime classEndTime;
    // Arrival time information
    private LocalDateTime professorArrivalTime;
    private LocalDateTime studentArrivalTime;
}
