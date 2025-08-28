package mk.ukim.finki.attendanceappserver.dto;

import lombok.Builder;
import lombok.Data;
import mk.ukim.finki.attendanceappserver.domain.enums.ReportPriority;
import mk.ukim.finki.attendanceappserver.domain.enums.ReportStatus;
import mk.ukim.finki.attendanceappserver.domain.enums.ReportType;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
public class ReportResponseDTO {
    private UUID id;
    private ReportType reportType;
    private ReportPriority priority;
    private String title;
    private String description;
    private String stepsToReproduce;
    private String userInfo;
    private String deviceInfo;
    private ReportStatus status;
    private String adminNotes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime resolvedAt;
}
