package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.*;
import mk.ukim.finki.attendanceappserver.domain.enums.AttendanceStatus;
import org.springframework.data.annotation.Id;
import jakarta.persistence.Column;
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

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private AttendanceStatus status;

    @Column(name = "proximity")
    private String proximity;
}
