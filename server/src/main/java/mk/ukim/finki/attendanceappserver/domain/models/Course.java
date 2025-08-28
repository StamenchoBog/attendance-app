package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.util.Set;

@Data
@Table("course")
public class Course {

    @Id
    @NonNull
    @Column("id")
    private Long id;

    @Column("study_year")
    private short studyYear;

    @Column("last_name_regex")
    private String lastNameRegex;

    @Column("semester_code")
    private String semesterCode;

    @Column("joined_subject_abbreviation")
    private String joinedSubjectAbbreviation;

    @Column("professor_id")
    private String professorId;

    @Column("assistant_id")
    private String assistantId;

    @Column("number_of_first_enrollments")
    private int numberOfFirstEnrollments;

    @Column("number_of_re_enrollments")
    private int numberOfReEnrollments;

    @Column("group_portion")
    private float groupPortion;

    @Column("professors")
    private Set<String> professors;

    @Column("assistants")
    private Set<String> assistants;

    @Column("groups")
    private String groups;

    @Column("english")
    private boolean english;

}
