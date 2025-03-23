package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;

@Data
@Builder(toBuilder = true)
@Table(name = "student_attendance")
public class StudentAttendance {

    @Id
    @Column(name = "id")
    private int id;

    @Column(name = "student_student_index")
    private String studentIndex;

    @Column(name = "professor_class_session_id")
    private int professorClassSessionId;

    @Column(name = "arrival_time")
    private LocalDateTime arrivalTime;
}
