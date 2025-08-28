package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;

@Data
@Table("joined_subject")
public class JoinedSubject {

    @Id
    @NonNull
    @Column("abbreviation")
    private String abbreviation;

    @Column("name")
    private String name;

    @Column("codes")
    private String codes;

    @Column("semester_type")
    private String semesterType;

    @Column("main_subject_id")
    private String mainSubjectId;

    @Column("weekly_lecture_classes")
    private int weeklyLectureClasses;

    @Column("weekly_auditorium_classes")
    private int weeklyAuditoriumClasses;

    @Column("weekly_lab_classes")
    private int weeklyLabClasses;

    @Column("cycle")
    private String cycle;

    @Column("last_updated_time")
    private LocalDateTime lastUpdatedTime;

    @Column("last_updated_user")
    private String lastUpdateUser;

    @Column("validation_message")
    private String validationMessage;

}
