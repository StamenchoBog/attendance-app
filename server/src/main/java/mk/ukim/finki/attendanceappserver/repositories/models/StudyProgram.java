package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.EntityListeners;
import lombok.Data;
import org.springframework.data.annotation.Id;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table(name = "study_program")
@EntityListeners(PreventAnyUpdate.class)
public class StudyProgram {

    @Id
    @Column("code")
    private String code;

    @Column("name")
    private String name;
}
