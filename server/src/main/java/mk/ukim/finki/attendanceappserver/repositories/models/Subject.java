package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;

import java.time.LocalDateTime;

@Data
@Table(name = "subject")
@EntityListeners(PreventAnyUpdate.class)
public class Subject {

    @Id
    @NonNull
    @Column(name = "id")
    private String id;

    @NonNull
    @Column(name = "name")
    private String name;

    @Column(name = "name_en")
    private String nameEn;

    @Column(name = "semester")
    private String semester;

    @Column(name = "weekly_lecture_classes")
    private int weeklyLectureClasses;

    @Column(name = "weekly_auditorium_classes")
    private int weeklyAuditoriumClasses;

    @Column(name = "weekly_lab_classes")
    private int weeklyLabClasses;

    @Column(name = "abbreviation")
    private String abbreviation;

    @Column(name = "default_semester")
    private short defaultSemester;

    @Column(name = "accreditation_year")
    private String accreditationYear;

    @Column(name = "activity_points")
    private short activityPoints;

    @Column(name = "content", length = 8000)
    private String content;

    @Column(name = "content_en", length = 8000)
    private String contentEn;

    @Column(name = "credits")
    private float credits;

    @Column(name = "cycle")
    private String cycle;

    @Column(name = "dependencies", length = 5000)
    private String dependencies;

    @Column(name = "exam_points")
    private short examPoints;

    @Column(name = "exercise_points")
    private String exercisePoints;

    @Column(name = "goals_description", length = 8000)
    private String goalsDescription;

    @Column(name = "goals_description_en", length = 8000)
    private String goalsDescriptionEn;

    @Column(name = "homework_hours")
    private String homeworkHours;

    @Column(name = "language")
    private String language;

    @Column(name = "learning_methods", length = 8000)
    private String learningMethods;

    @Column(name = "lecture_hours")
    private String lectureHours;

    @Column(name = "project_hours")
    private String projectHours;

    @Column(name = "project_points")
    private short projectPoints;

    @Column(name = "self_learning_points")
    private String selfLearningPoints;

    @Column(name = "signature_condition")
    private String signatureCondition;

    @Column(name = "test_points")
    private short testPoints;

    @Column(name = "total_hours")
    private String totalHours;

    @Column(name = "quality_control", length = 4000)
    private String qualityControl;

    @Column(name = "placeholder")
    private boolean placeholder;

    @Column(name = "dependency_type")
    private String dependencyType;

    @Column(name = "last_update_time")
    private LocalDateTime lastUpdateTime;

    @Column(name = "last_update_user")
    private String lastUpdateUser;

}
