package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;

import java.time.LocalDateTime;
import java.util.Set;

@Data
@Table(name = "subject_exam")
@EntityListeners(PreventAnyUpdate.class)
public class SubjectExam {

    @Id
    @NonNull
    @Column(name = "id")
    private String id;

    @Column(name = "session_name")
    private String sessionName;

    @Column(name = "duration_minutes")
    private int durationMinutes;

    @Column(name = "previous_year_attendants_number")
    private int previousYearAttendantsNumber;

    @Column(name = "attendants_number")
    private int attendantsNumber;

    @Column(name = "num_repetitions")
    private int numberOfRepetitions;

    @Column(name = "from_time")
    private LocalDateTime fromTime;

    @Column(name = "to_time")
    private LocalDateTime toTime;

    @Column(name = "comment", length = 5000)
    private String comment;

    @Column(name = "definition_id")
    private String definitionId;

    @Column(name = "previous_year_total_students")
    private int previousYearTotalStudents;

    @Column(name = "total_students")
    private int totalStudents;

    @Column(name = "expected_number")
    private int expectedNumber;

    @ManyToMany(fetch = FetchType.LAZY, targetEntity = Room.class)
    @JoinTable(
            name = "subject_exam_rooms",
            joinColumns = @JoinColumn(name = "rooms_name"),
            inverseJoinColumns = @JoinColumn(name = "subject_exam_id")
    )
    private Set<Room> rooms;
}
