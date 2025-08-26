package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDate;

@Data
@Table("year_exam_session")
public class YearExamSession {

    @Id
    @NonNull
    @Column("id")
    private String id;

    @Column("session")
    private String session;

    @Column("semester_code")
    private String semesterCode;

    @Column("session_start")
    private LocalDate sessionStart;

    @Column("session_end")
    private LocalDate sessionEnd;

    @Column("enrollment_start_date")
    private LocalDate enrollmentStartDate;

    @Column("enrollment_end_date")
    private LocalDate enrollmentEndDate;

    @Column("year")
    private String year;
}
