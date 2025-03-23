package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.annotation.Id;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Table(name = "professor_class_session")
@EntityListeners(PreventAnyUpdate.class)
public class ProfessorClassSession {

    @Id
    @Column(name = "id", unique = true, nullable = false)
    private int id;

    @Column(name = "professor_id")
    private String professor;

    @Column(name = "scheduled_class_session_id")
    private int scheduledClassSessionId;

    @Column(name = "date")
    private LocalDate date;

    @Column(name = "professor_arrival_time")
    private LocalDateTime professorArrivalTime;

    @Column(name = "attendance_token")
    private String attendanceToken;
}
