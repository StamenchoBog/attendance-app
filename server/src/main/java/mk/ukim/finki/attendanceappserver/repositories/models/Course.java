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
@Table("course")
@EntityListeners(PreventAnyUpdate.class)
public class Course {

    @Id
    @NonNull
    @Column(name = "id")
    private Long id;

    @Column(name = "study_year")
    private short studyYear;

    @Column(name = "last_name_regex")
    private String lastNameRegex;

    @Column(name = "semester_code")
    private String semesterCode;

    @Column(name = "joined_subject_abbreviation")
    private String joinedSubjectAbbreviation;

    @Column(name = "professor_id")
    private String professorId;

    @Column(name = "assistant_id")
    private String assistantId;

    @Column(name = "number_of_first_enrollments")
    private int numberOfFirstEnrollments;

    @Column(name = "number_of_re_enrollments")
    private int numberOfReEnrollments;

    @Column(name = "group_portion")
    private float groupPortion;

    @Column(name = "professors")
    @Convert(converter = StringToSetConverter.class)
    private Set<String> professors;

    @Column(name = "assistants")
    @Convert(converter = StringToSetConverter.class)
    private Set<String> assistants;

    @Column(name = "groups")
    private String groups;

    @Column(name = "english")
    private boolean english;

}
