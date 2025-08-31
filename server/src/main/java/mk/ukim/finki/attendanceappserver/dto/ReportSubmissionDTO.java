package mk.ukim.finki.attendanceappserver.dto;

import lombok.Builder;
import lombok.Data;
import mk.ukim.finki.attendanceappserver.domain.enums.ReportPriority;
import mk.ukim.finki.attendanceappserver.domain.enums.ReportType;

import java.util.UUID;

@Data
@Builder
public class ReportSubmissionDTO {
    private ReportType reportType;
    private ReportPriority priority;
    private String title;
    private String description;
    private String stepsToReproduce;
    private String studentIndex;
    private String deviceId;
}
