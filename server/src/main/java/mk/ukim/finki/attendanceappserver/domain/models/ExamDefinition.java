package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;

@Data
@Table("exam_definition")
public class ExamDefinition {

    @Id
    @NonNull
    @Column("id")
    private String id;

    @Column("subject_abbreviation")
    private String subjectAbbreviation;

    @Column("exam_session")
    private String examSession;

    @Column("duration_minutes")
    private int durationMinutes;

    @Column("type")
    private String type;

    @Column("note")
    private String note;

    @Column("last_update_time")
    private LocalDateTime lastUpdateTime;

    @Column("last_update_user")
    private LocalDateTime lastUpdateUser;
}
