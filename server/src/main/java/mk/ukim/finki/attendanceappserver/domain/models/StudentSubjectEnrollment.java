package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.util.Set;

@Data
@Table("student_subject_enrollment")
public class StudentSubjectEnrollment {

    @Id
    @NonNull
    @Column("id")
    private String id;

    @NonNull
    @Column("semester_code")
    private String semesterCode;

    @NonNull
    @Column("student_student_index")
    private String studentIndex;

    @NonNull
    @Column("subject_id")
    private String subject;

    @Column("valid")
    private boolean valid;

    @Column("invalid_note")
    private String invalidNote;

    @Column("num_enrollments")
    private short numberOfEnrollments;

    @Column("group_name")
    private String groupName;

    @Column("group_id")
    private String group;

    @Column("joined_subject_abbreviation")
    private String joinedSubjectAbbreviation;

    @Column("professor_id")
    private String professorId;

    @Column("professors")
    private Set<String> professors;

    @Column("assistants")
    private Set<String> assistants;

    @Column("course_id")
    private String courseId;
}
