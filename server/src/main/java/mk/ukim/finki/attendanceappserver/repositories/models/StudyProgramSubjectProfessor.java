package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table(name = "study_program_subject_professor")
@EntityListeners(PreventAnyUpdate.class)
public class StudyProgramSubjectProfessor {

    @Id
    @NonNull
    @Column(name = "id")
    private String id;

    @OneToOne(fetch = FetchType.LAZY)
    @Column(name = "study_program_subject")
    private StudyProgramSubject studyProgramSubject;

    @OneToMany(fetch = FetchType.LAZY)
    private Professor professor;

    @Column(name = "order")
    private float order;
}
