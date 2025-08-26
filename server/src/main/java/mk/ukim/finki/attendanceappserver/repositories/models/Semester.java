package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Data;
import org.springframework.data.annotation.Id;
import lombok.NonNull;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDate;

@Data
@Table("semester")
public class Semester {

    @Id
    @NonNull
    @Column("code")
    private String code;

    @Column("semester_type")
    private String semesterType;

    @Column("year")
    private String year;

    @Column("start_date")
    private LocalDate startDate;

    @Column("end_date")
    private LocalDate endDate;

    @Column("enrollment_start_date")
    private LocalDate enrollmentStartDate;

    @Column("enrollment_end_date")
    private LocalDate enrollmentEndDate;

    @Column("state")
    private String state;
}
