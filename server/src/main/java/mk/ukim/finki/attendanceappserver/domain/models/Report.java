package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.Builder;
import lombok.Data;
import mk.ukim.finki.attendanceappserver.domain.enums.ReportPriority;
import mk.ukim.finki.attendanceappserver.domain.enums.ReportStatus;
import mk.ukim.finki.attendanceappserver.domain.enums.ReportType;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@Table("attendance_problem_report")
public class Report {

    @Id
    @Column("id")
    private UUID id;

    @Column("report_type")
    private ReportType reportType;

    @Column("priority")
    private ReportPriority priority;

    @Column("title")
    private String title;

    @Column("description")
    private String description;

    @Column("steps_to_reproduce")
    private String stepsToReproduce;

    @Column("student_index")
    private String studentIndex;

    @Column("device_id")
    private String deviceId;

    @Column("status")
    private ReportStatus status;

    @Column("admin_notes")
    private String adminNotes;

    @Column("created_at")
    private LocalDateTime createdAt;

    @Column("updated_at")
    private LocalDateTime updatedAt;

    @Column("resolved_at")
    private LocalDateTime resolvedAt;
}
