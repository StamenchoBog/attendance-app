package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Table("professor_class_session")
public class ProfessorClassSession {

    @Id
    @Column("id")
    private int id;

    @Column("professor_id")
    private String professor;

    @Column("scheduled_class_session_id")
    private int scheduledClassSessionId;

    @Column("date")
    private LocalDate date;

    @Column("professor_arrival_time")
    private LocalDateTime professorArrivalTime;

    @Column("attendance_token")
    private String attendanceToken;

    @Column("token_expiration_time")
    private LocalDateTime tokenExpirationTime;
}
