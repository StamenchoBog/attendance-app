package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;

import java.time.LocalDateTime;

@Data
@Table(name = "exam_definition")
@EntityListeners(PreventAnyUpdate.class)
public class ExamDefinition {

    @Id
    @NonNull
    @Column(name = "id")
    private String id;

    @Column(name = "subject_abbreviation")
    private String subjectAbbreviation;

    @Column(name = "exam_session")
    private String examSession;

    @Column(name = "duration_minutes")
    private int durationMinutes;

    @Column(name = "type")
    private String type;

    @Column(name = "note")
    private String note;

    @Column(name = "last_update_time")
    private LocalDateTime lastUpdateTime;

    @Column(name = "last_update_user")
    private LocalDateTime lastUpdateUser;
}
