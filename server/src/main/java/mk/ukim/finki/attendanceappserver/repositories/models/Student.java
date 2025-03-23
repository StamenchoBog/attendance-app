package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table(name = "student")
@EntityListeners(PreventAnyUpdate.class)
public class Student {

    @Id
    @NonNull
    @Column("student_index")
    private String studentIndex;

    @Column("email")
    private String email;

    @Column("last_name")
    private String lastName;

    @Column("name")
    private String name;

    @Column("parent_name")
    private String parentName;

    @Column("study_program_code")
    private String studyProgramCode;
}
