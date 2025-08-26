package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.math.BigInteger;
import java.sql.Timestamp;

@Data
@Table("professor_engagement")
public class ProfessorEngagement {

    @Id
    @NonNull
    private String id;

    @NonNull
    @Column("semester_code")
    private String semesterCode;

    @NonNull
    @Column("subject_abbreviation")
    private String subjectAbbreviation;

    @Column("class_type")
    private String classType;

    @Column("number_of_classes")
    private BigInteger numberOfClasses;

    @Column("shared_with_other_teacher")
    private boolean sharedWithOtherTeacher;

    private String language;

    @Column("number_of_students")
    private short numberOfStudents;

    @Column("consultative")
    private boolean consultative;

    @Column("note")
    private String note;

    @Column("professor_id")
    private String professor;

    @Column("last_updated_time")
    private Timestamp lastUpdatedTime;

    @Column("last_updated_user")
    private String lastUpdatedUser;

    @Column("validation_message")
    private String validationMessage;

    @Column("calculated_number_of_classes")
    private float calculatedNumberOfClasses;

    @Column("calculated_number_of_students")
    private short calculatedNumberOfStudents;
}
