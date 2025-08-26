package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.Builder;
import lombok.Data;
import mk.ukim.finki.attendanceappserver.domain.enums.DeviceLinkStatus;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@Table("device_link_request")
public class DeviceLinkRequest {

    @Id
    @Column("id")
    private UUID id;

    @Column("student_index")
    private String studentIndex;

    @Column("device_id")
    private String deviceId;

    @Column("device_name")
    private String deviceName;

    @Column("device_os")
    private String deviceOs;

    @Column("request_timestamp")
    private LocalDateTime requestTimestamp;

    @Enumerated(EnumType.STRING)
    @Column("status")
    private DeviceLinkStatus status;

    @Column("notes")
    private String notes;
}
