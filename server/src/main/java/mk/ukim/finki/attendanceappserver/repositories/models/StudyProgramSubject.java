package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.annotation.Id;

@Data
@Table(name = "study_program_subject")
@EntityListeners(PreventAnyUpdate.class)
public class StudyProgramSubject {

    @Id
    @NonNull
    @Column(name = "id")
    private String id;

    @OneToMany(fetch = FetchType.LAZY)
    @Column(name = "subject_id")
    private Subject subject;

    @Column(name = "mandatory")
    private boolean mandatory;

    @Column(name = "semester")
    private short semester;

    @Column(name = "order")
    private float order;

    @OneToMany(fetch = FetchType.LAZY)
    @Column(name = "study_program_code")
    private StudyProgram studyProgram;

    @Column(name = "dependencies_override", length = 5000)
    private String dependenciesOverride;

    @Column(name = "subject_group")
    private String subjectGroup;
}
