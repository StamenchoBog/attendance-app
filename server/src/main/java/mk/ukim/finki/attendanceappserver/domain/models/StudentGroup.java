package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("student_group")
public class StudentGroup {

    @Id
    @NonNull
    @Column("id")
    private Long id;

    @Column("name")
    private String name;

    @Column("study_year")
    private short studyYear;

    @Column("last_name_regex")
    private String lastNameRegex;

    @Column("semester_code")
    private String semesterCode;

    @Column("programs")
    private String programs;

    @Column("english")
    private boolean english;

    @Column("default_size")
    private int defaultSize;
}
