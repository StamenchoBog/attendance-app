package mk.ukim.finki.attendanceappserver.dto.db;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalTime;

@Getter
@Setter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProfessorClassSession {
    private String professorClassSessionId;
    private String scheduledClassSessionId;
    private String subjectId;
    private String type;
    private String roomName;
    private LocalDate date;
    private LocalTime startTime;
    private LocalTime endTime;
    private String subjectName;
}
