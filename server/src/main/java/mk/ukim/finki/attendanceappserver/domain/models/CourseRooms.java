package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.Data;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("course_rooms")
public class CourseRooms {

    @Column("course_id")
    private int courseId;

    @Column("room_name")
    private String roomName;
}
