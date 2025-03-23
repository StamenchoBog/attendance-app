package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;

import java.time.LocalDate;

@Data
@Table(name = "year_exam_session")
@EntityListeners(PreventAnyUpdate.class)
public class YearExamSession {

    @Id
    @NonNull
    @Column(name = "id")
    private String id;

    @Column(name = "session")
    private String session;

    @Column(name = "semester_code")
    private String semesterCode;

    @Column(name = "session_start")
    private LocalDate sessionStart;

    @Column(name = "session_end")
    private LocalDate sessionEnd;

    @Column(name = "enrollment_start_date")
    private LocalDate enrollmentStartDate;

    @Column(name = "enrollment_end_date")
    private LocalDate enrollmentEndDate;

    @Column(name = "year")
    private String year;
}
