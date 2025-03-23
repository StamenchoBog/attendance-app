package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;

@Data
@Table("joined_subject")
@EntityListeners(PreventAnyUpdate.class)
public class JoinedSubject {

    @Id
    @NonNull
    @Column(name = "abbreviation")
    private String abbreviation;

    @Column(name = "name", length = 100)
    private String name;

    @Column(name = "codes")
    private String codes;

    @Column(name = "semester_type")
    private String semesterType;

    @Column(name = "main_subject_id")
    private String mainSubjectId;

    @Column(name = "weekly_lecture_classes")
    private int weeklyLectureClasses;

    @Column(name = "weekly_auditorium_classes")
    private int weeklyAuditoriumClasses;

    @Column(name = "weekly_lab_classes")
    private int weeklyLabClasses;

    @Column(name = "cycle")
    private String cycle;

    @Column(name = "last_updated_time")
    private LocalDateTime lastUpdatedTime;

    @Column(name = "last_updated_user")
    private String lastUpdateUser;

    @Column(name = "validation_message", length = 4000)
    private String validationMessage;

}
