package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Getter;
import lombok.NonNull;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Getter
@Setter
@Table("course")
public class Course {

    @Id
    @NonNull
    private Long id;

    @Column("study_year")
    private short study_year;

    @Column("last_name_regex")
    private String last_name_regex;

    @Column("semester_code")
    private String semester_code;

    @Column("joined_subject_abbreviation")
    private String joined_subject_abbreviation;

    @Column("professor_id")
    private String professor_id;

    @Column("assistant_id")
    private String assistant_id;

    @Column("number_of_first_enrollments")
    private int number_of_first_enrollments;

    @Column("number_of_re_enrollments")
    private int number_of_re_enrollments;

    @Column("group_portion")
    private float group_portion;

    @Column("professors")
    private String professors;

    @Column("assistants")
    private String assistants;

    @Column("groups")
    private String groups;

    @Column("english")
    private boolean english;
}
