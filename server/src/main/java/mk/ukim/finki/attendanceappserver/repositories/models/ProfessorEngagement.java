package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.annotation.Id;

import java.math.BigInteger;
import java.sql.Timestamp;

@Data
@Table(name = "professor_engagement")
@EntityListeners(PreventAnyUpdate.class)
public class ProfessorEngagement {

    @Id
    @NonNull
    private String id;

    @NonNull
    @Column(name = "semester_code")
    private String semesterCode;

    @NonNull
    @Column(name = "subject_abbreviation")
    private String subjectAbbreviation;

    @Column(name = "class_type")
    private String classType;

    @Column(name = "number_of_classes")
    private BigInteger numberOfClasses;

    @Column(name = "shared_with_other_teacher")
    private boolean sharedWithOtherTeacher;

    private String language;

    @Column(name = "number_of_students")
    private short numberOfStudents;

    @Column(name = "consultative")
    private boolean consultative;

    @Column(name = "note", length = 2000)
    private String note;

    @Column(name = "professor_id")
    private String professor;

    @Column(name = "last_updated_time")
    private Timestamp lastUpdatedTime;

    @Column(name = "last_updated_user")
    private String lastUpdatedUser;

    @Column(name = "validation_message", length = 4000)
    private String validationMessage;

    @Column(name = "calculated_number_of_classes")
    private float calculatedNumberOfClasses;

    @Column(name = "calculated_number_of_students")
    private short calculatedNumberOfStudents;
}
