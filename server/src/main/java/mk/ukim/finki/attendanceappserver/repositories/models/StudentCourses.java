package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.Column;
import lombok.Builder;
import lombok.Data;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Builder(toBuilder = true)
@Table(name = "student_courses")
public class StudentCourses {

    @Column(name = "id")
    private int id;

    @Column(name = "student_student_index")
    private String studentIndex;

    @Column(name = "course_id")
    private String courseId;
}
