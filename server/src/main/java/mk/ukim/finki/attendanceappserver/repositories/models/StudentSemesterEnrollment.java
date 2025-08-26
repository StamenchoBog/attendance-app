package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("student_semester_enrollment")
public class StudentSemesterEnrollment {

    @Id
    @NonNull
    @Column("id")
    private String id;

    @Column("semester_code")
    private String semesterCode;

    @Column("student_student_index")
    private String studentIndex;

    @Column("payment_amount")
    private float paymentAmount;

    @Column("payment_confirmed")
    private boolean paymentConfirmed;

    @Column("valid")
    private boolean valid;

    @Column("invalid_notice")
    private String invalidNotice;
}
