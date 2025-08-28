package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;

@Data
@Table("scheduled_class_session")
public class ScheduledClassSession {

    @Id
    @Column("id")
    private int id;

    @Column("course_id")
    private int courseId;

    @Column("room_name")
    private String roomName;

    @Column("type")
    private String type;

    @Column("start_time")
    private LocalDateTime startTime;

    @Column("end_time")
    private LocalDateTime endTime;

    @Column("day_of_week")
    private short dayOfWeek;

    @Column("semester_code")
    private String semesterCode;
}
