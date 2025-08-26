package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Builder;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@Table("student_device")
public class StudentDevice {

    @Id
    @Column("id")
    private UUID id;

    @Column("student_student_index")
    private String studentIndex;

    @Column("device_id")
    private String deviceId;

    @Column("device_name")
    private String deviceName;

    @Column("device_os")
    private String deviceOs;

    @Column("created_timestamp")
    private LocalDateTime createdTimestamp;
}
