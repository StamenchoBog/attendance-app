package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.Table;
import lombok.Data;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;

@Data
@Table(name = "subject_exam_rooms")
@EntityListeners(PreventAnyUpdate.class)
public class SubjectExamRooms {

    @Column(name = "subject_exam_id")
    private String subjectExamId;

    @Column(name = "rooms_name")
    private String roomsName;
}
