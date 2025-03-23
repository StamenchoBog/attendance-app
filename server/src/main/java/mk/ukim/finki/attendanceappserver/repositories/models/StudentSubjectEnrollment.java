package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import mk.ukim.finki.attendanceappserver.repositories.models.converters.StringToSetConverter;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

import java.util.Set;

@Data
@Table(name = "student_subject_enrollment")
@EntityListeners(PreventAnyUpdate.class)
public class StudentSubjectEnrollment {

    @Id
    @NonNull
    @Column(name = "id")
    private String id;

    @NonNull
    @Column(name = "semester_code")
    private String semesterCode;

    @NonNull
    @Column(name = "student_student_index")
    private String studentIndex;

    @NonNull
    @Column(name = "subject_id")
    private String subject;

    @Column(name = "valid")
    private boolean valid;

    @Column(name = "invalid_note", length = 4000)
    private String invalidNote;

    @Column(name = "num_enrollments")
    private short numberOfEnrollments;

    @Column(name = "group_name")
    private String groupName;

    @Column(name = "group_id")
    private String group;

    @Column(name = "joined_subject_abbreviation")
    private String joinedSubjectAbbreviation;

    @Column(name = "professor_id")
    private String professorId;

    @Convert(converter = StringToSetConverter.class)
    @Column(name = "professors", length = 1000)
    private Set<String> professors;

    @Convert(converter = StringToSetConverter.class)
    @Column(name = "assistants", length = 1000)
    private Set<String> assistants;

    @ManyToMany(fetch = FetchType.LAZY)
    @Column(name = "course_id")
    private String courseId;
}
