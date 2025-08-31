package mk.ukim.finki.attendanceappserver.dto.db;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@Setter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ClassSessionOverview {

    private String professorClassSessionId;
    private String scheduledClassSessionId;

    // Professor information
    private String professorId;
    private String professorName;

    // Course information
    private String courseId;
    private LocalDate classDate;
    private String classType;
    private String classRoomName;

    // Subject information
    private String subjectId;
    private String subjectName;

    // Class session information
    private LocalTime classStartTime;
    private LocalTime classEndTime;
    private Boolean hasClassStarted;

    // Attendance verification status for color coding
    private String attendanceStatus; // e.g., "verified", "registered", "pending", "absent", "not_attended"
}
