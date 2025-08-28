package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.Builder;
import lombok.Data;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Builder(toBuilder = true)
@Table(name = "student_courses")
public class StudentCourses {

    @Column("id")
    private int id;

    @Column("student_student_index")
    private String studentIndex;

    @Column("course_id")
    private String courseId;
}
