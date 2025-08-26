package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("study_program")
public class StudyProgram {

    @Id
    @Column("code")
    private String code;

    @Column("name")
    private String name;
}
