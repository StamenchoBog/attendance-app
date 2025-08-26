package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;
import java.util.Set;

@Data
@Table("subject_exam")
public class SubjectExam {

    @Id
    @NonNull
    @Column("id")
    private String id;

    @Column("session_name")
    private String sessionName;

    @Column("duration_minutes")
    private int durationMinutes;

    @Column("previous_year_attendants_number")
    private int previousYearAttendantsNumber;

    @Column("attendants_number")
    private int attendantsNumber;

    @Column("num_repetitions")
    private int numberOfRepetitions;

    @Column("from_time")
    private LocalDateTime fromTime;

    @Column("to_time")
    private LocalDateTime toTime;

    @Column("comment")
    private String comment;

    @Column("definition_id")
    private String definitionId;

    @Column("previous_year_total_students")
    private int previousYearTotalStudents;

    @Column("total_students")
    private int totalStudents;

    @Column("expected_number")
    private int expectedNumber;

    private Set<Room> rooms;
}
