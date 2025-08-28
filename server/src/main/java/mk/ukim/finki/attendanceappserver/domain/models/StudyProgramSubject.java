package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("study_program_subject")
public class StudyProgramSubject {

    @Id
    @NonNull
    @Column("id")
    private String id;

    @Column("subject_id")
    private String subjectId;

    @Column("mandatory")
    private boolean mandatory;

    @Column("semester")
    private short semester;

    @Column("order")
    private float order;

    @Column("study_program_code")
    private String studyProgramCode;

    @Column("dependencies_override")
    private String dependenciesOverride;

    @Column("subject_group")
    private String subjectGroup;
}
