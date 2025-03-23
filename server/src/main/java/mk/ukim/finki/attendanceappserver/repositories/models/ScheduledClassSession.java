package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.Id;
import lombok.Data;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;

@Data
@Table(name = "scheduled_class_session")
@EntityListeners(PreventAnyUpdate.class)
public class ScheduledClassSession {

    @Id
    @Column(name = "id")
    private int id;

    @Column(name = "course_id")
    private int courseId;

    @Column(name = "room_name")
    private String roomName;

    @Column(name = "type")
    private String type;

    @Column(name = "start_time")
    private LocalDateTime startTime;

    @Column(name = "end_time")
    private LocalDateTime endTime;

    @Column(name = "day_of_week")
    private short dayOfWeek;

    @Column(name = "semester_code")
    private String semesterCode;
}
