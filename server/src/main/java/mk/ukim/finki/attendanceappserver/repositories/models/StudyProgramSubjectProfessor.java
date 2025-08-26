package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("study_program_subject_professor")
public class StudyProgramSubjectProfessor {

    @Id
    @NonNull
    @Column("id")
    private String id;

    @Column("study_program_subject_id")
    private String studyProgramSubjectId;

    @Column("professor_id")
    private String professorId;

    @Column("order")
    private float order;
}
