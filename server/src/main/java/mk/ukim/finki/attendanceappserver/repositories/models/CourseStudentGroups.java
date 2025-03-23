package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import lombok.Data;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("course_student_groups")
@EntityListeners(PreventAnyUpdate.class)
public class CourseStudentGroups {

    @Column(name = "course_id")
    private int courseId;

    @Column(name = "student_groups_id")
    private int studentGroupsId;
}
