package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table(name = "student_group")
@EntityListeners(PreventAnyUpdate.class)
public class StudentGroup {

    @Id
    @NonNull
    @Column(name = "id")
    private Long id;

    @Column(name = "name")
    private String name;

    @Column(name = "study_year")
    private short studyYear;

    @Column(name = "last_name_regex")
    private String lastNameRegex;

    @OneToOne(fetch = FetchType.LAZY)
    @Column(name = "semester_code")
    private String semesterCode;

    @Column(name = "programs")
    private String programs;

    @Column(name = "english")
    private boolean english;

    @Column(name = "default_size")
    private int defaultSize;
}
