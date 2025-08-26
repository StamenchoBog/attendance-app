package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Data;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("subject_exam_rooms")
public class SubjectExamRooms {

    @Column("subject_exam_id")
    private String subjectExamId;

    @Column("rooms_name")
    private String roomsName;
}
