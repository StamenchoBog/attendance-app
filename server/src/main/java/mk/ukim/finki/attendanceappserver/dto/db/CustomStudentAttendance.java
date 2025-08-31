package mk.ukim.finki.attendanceappserver.dto.db;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CustomStudentAttendance {

    private String studentAttendanceId;
    private String studentIndex;
    private String professorClassSessionId;
    private String scheduledClassSessionId;
    private LocalDateTime studentArrivalTime;

    // Joined student information
    private String studentName;
    private String studyProgramCode;

    // Joined professor information
    private String professorId;
    private String professorName;

    // Joined course/class information
    private String courseId;
    private LocalDate classDate;
    private String classType;
    private String classRoomName;
    private LocalTime classStartTime;
    private LocalTime classEndTime;
    private LocalDateTime professorArrivalTime;

    // Status field
    private String status;
}
