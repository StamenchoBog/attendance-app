package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Data;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("course_student_groups")
public class CourseStudentGroups {

    @Column("course_id")
    private int courseId;

    @Column("student_groups_id")
    private int studentGroupsId;
}
