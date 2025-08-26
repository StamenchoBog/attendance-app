package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.*;
import mk.ukim.finki.attendanceappserver.domain.enums.AttendanceStatus;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;

@Data
@Builder(toBuilder = true)
@Table(name = "student_attendance")
public class StudentAttendance {

    @Id
    @Column("id")
    private int id;

    @Column("student_student_index")
    private String studentIndex;

    @Column("professor_class_session_id")
    private int professorClassSessionId;

    @Column("arrival_time")
    private LocalDateTime arrivalTime;

    @Column("status")
    private AttendanceStatus status;

    @Column("proximity")
    private String proximity;
}
