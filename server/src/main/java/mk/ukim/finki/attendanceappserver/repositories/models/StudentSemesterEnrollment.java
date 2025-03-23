package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table(name = "student_semester_enrollment")
@EntityListeners(PreventAnyUpdate.class)
public class StudentSemesterEnrollment {

    @Id
    @NonNull
    @Column(name = "id")
    private String id;

    @Column(name = "semester_code")
    private String semesterCode;

    @Column(name = "student_student_index")
    private String studentIndex;

    @Column(name = "payment_amount")
    private float paymentAmount;

    @Column(name = "payment_confirmed")
    private boolean paymentConfirmed;

    @Column(name = "valid")
    private boolean valid;

    @Column(name = "invalid_notice", length = 4000)
    private String invalidNotice;
}
