package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;

@Data
@Table("subject")
public class Subject {

    @Id
    @NonNull
    @Column("id")
    private String id;

    @NonNull
    @Column("name")
    private String name;

    @Column("name_en")
    private String nameEn;

    @Column("semester")
    private String semester;

    @Column("weekly_lecture_classes")
    private int weeklyLectureClasses;

    @Column("weekly_auditorium_classes")
    private int weeklyAuditoriumClasses;

    @Column("weekly_lab_classes")
    private int weeklyLabClasses;

    @Column("abbreviation")
    private String abbreviation;

    @Column("default_semester")
    private short defaultSemester;

    @Column("accreditation_year")
    private String accreditationYear;

    @Column("activity_points")
    private short activityPoints;

    @Column("content")
    private String content;

    @Column("content_en")
    private String contentEn;

    @Column("credits")
    private float credits;

    @Column("cycle")
    private String cycle;

    @Column("dependencies")
    private String dependencies;

    @Column("exam_points")
    private short examPoints;

    @Column("exercise_points")
    private String exercisePoints;

    @Column("goals_description")
    private String goalsDescription;

    @Column("goals_description_en")
    private String goalsDescriptionEn;

    @Column("homework_hours")
    private String homeworkHours;

    @Column("language")
    private String language;

    @Column("learning_methods")
    private String learningMethods;

    @Column("lecture_hours")
    private String lectureHours;

    @Column("project_hours")
    private String projectHours;

    @Column("project_points")
    private short projectPoints;

    @Column("self_learning_points")
    private String selfLearningPoints;

    @Column("signature_condition")
    private String signatureCondition;

    @Column("test_points")
    private short testPoints;

    @Column("total_hours")
    private String totalHours;

    @Column("quality_control")
    private String qualityControl;

    @Column("placeholder")
    private boolean placeholder;

    @Column("dependency_type")
    private String dependencyType;

    @Column("last_update_time")
    private LocalDateTime lastUpdateTime;

    @Column("last_update_user")
    private String lastUpdateUser;

}
