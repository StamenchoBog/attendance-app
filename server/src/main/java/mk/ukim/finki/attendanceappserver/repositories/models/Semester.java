package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import lombok.Data;
import org.springframework.data.annotation.Id;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDate;

@Data
@Table(name = "semester")
@EntityListeners(PreventAnyUpdate.class)
public class Semester {

    @Id
    @NonNull
    @Column(name = "code")
    private String code;

    @Column(name = "semester_type")
    private String semesterType;

    @Column(name = "year")
    private String year;

    @Column(name = "start_date")
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Column(name = "enrollment_start_date")
    private LocalDate enrollmentStartDate;

    @Column(name = "enrollment_end_date")
    private LocalDate enrollmentEndDate;

    @Column(name = "state")
    private String state;
}
