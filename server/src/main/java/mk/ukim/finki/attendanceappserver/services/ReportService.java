package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import mk.ukim.finki.attendanceappserver.domain.enums.ReportStatus;
import mk.ukim.finki.attendanceappserver.domain.enums.ReportType;
import mk.ukim.finki.attendanceappserver.dto.ReportSubmissionDTO;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.domain.repositories.ReportRepository;
import mk.ukim.finki.attendanceappserver.domain.models.Report;

import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.UUID;

@Slf4j
@Service
@AllArgsConstructor
public class ReportService {

    private final ReportRepository reportRepository;

    public Mono<APIResponse<UUID>> submitReport(ReportSubmissionDTO reportDTO) {
        return validateReportData(reportDTO)
                .flatMap(this::createAndSaveReport)
                .map(savedReport -> {
                    log.info("Report submitted successfully with ID: {}", savedReport.getId());
                    return APIResponse.success(savedReport.getId());
                })
                .onErrorResume(this::handleSubmissionError);
    }

    private Mono<ReportSubmissionDTO> validateReportData(ReportSubmissionDTO reportDTO) {
        if (!StringUtils.hasText(reportDTO.getTitle())) {
            return Mono.error(new IllegalArgumentException("Title is required"));
        }
        if (!StringUtils.hasText(reportDTO.getDescription())) {
            return Mono.error(new IllegalArgumentException("Description is required"));
        }
        if (reportDTO.getTitle().trim().length() < 5) {
            return Mono.error(new IllegalArgumentException("Title must be at least 5 characters long"));
        }
        if (reportDTO.getDescription().trim().length() < 10) {
            return Mono.error(new IllegalArgumentException("Description must be at least 10 characters long"));
        }
        if (reportDTO.getReportType() == null) {
            return Mono.error(new IllegalArgumentException("Report type is required"));
        }
        if (reportDTO.getPriority() == null) {
            return Mono.error(new IllegalArgumentException("Priority is required"));
        }
        if (!StringUtils.hasText(reportDTO.getStudentIndex())) {
            return Mono.error(new IllegalArgumentException("Student index is required"));
        }

        return Mono.just(reportDTO);
    }

    private Mono<Report> createAndSaveReport(ReportSubmissionDTO reportDTO) {
        Report report = Report.builder()
                .reportType(reportDTO.getReportType())
                .priority(reportDTO.getPriority())
                .title(reportDTO.getTitle().trim())
                .description(reportDTO.getDescription().trim())
                .stepsToReproduce(StringUtils.hasText(reportDTO.getStepsToReproduce())
                        ? reportDTO.getStepsToReproduce().trim() : null)
                .studentIndex(reportDTO.getStudentIndex())
                .deviceId(reportDTO.getDeviceId())
                .status(ReportStatus.NEW)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        return reportRepository.save(report)
                .doOnSuccess(savedReport -> log.debug("Report saved to database: {}", savedReport.getId()))
                .doOnError(error -> log.error("Failed to save report to database", error));
    }

    private Mono<APIResponse<UUID>> handleSubmissionError(Throwable error) {
        log.error("Error submitting report", error);

        if (error instanceof IllegalArgumentException) {
            return Mono.just(APIResponse.error(error.getMessage(), 400));
        }

        return Mono.just(APIResponse.error("Failed to save report", 500));
    }

    public Mono<APIResponse<Flux<Report>>> getAllReports() {
        return Mono.fromCallable(() -> {
            log.debug("Fetching all reports");
            return APIResponse.success(
                    reportRepository.findAll()
                            .sort((r1, r2) -> r2.getCreatedAt().compareTo(r1.getCreatedAt()))
            );
        }).onErrorReturn(APIResponse.error("Failed to fetch reports", 500));
    }

    public Mono<APIResponse<Flux<Report>>> getReportsByStatus(String status) {
        return Mono.fromCallable(() -> ReportStatus.fromString(status))
                .map(reportStatus -> {
                    log.debug("Fetching reports with status: {}", reportStatus);
                    return APIResponse.success(
                            reportRepository.findByStatusOrderByCreatedAtDesc(reportStatus)
                    );
                })
                .onErrorReturn(APIResponse.error("Invalid status: " + status, 400));
    }

    public Mono<APIResponse<Flux<Report>>> getReportsByType(String reportType) {
        return Mono.fromCallable(() -> ReportType.fromString(reportType))
                .map(type -> {
                    log.debug("Fetching reports with type: {}", type);
                    return APIResponse.success(
                            reportRepository.findByReportTypeOrderByCreatedAtDesc(type)
                    );
                })
                .onErrorReturn(APIResponse.error("Invalid report type: " + reportType, 400));
    }

    public Mono<APIResponse<Report>> updateReportStatus(UUID reportId, String status, String adminNotes) {
        return Mono.fromCallable(() -> ReportStatus.fromString(status))
                .flatMap(reportStatus -> updateReportWithStatus(reportId, reportStatus, adminNotes))
                .onErrorResume(error -> {
                    if (error instanceof IllegalArgumentException) {
                        return Mono.just(APIResponse.error("Invalid status: " + status, 400));
                    }
                    log.error("Error updating report status for ID: {}", reportId, error);
                    return Mono.just(APIResponse.error("Failed to update report", 500));
                });
    }

    private Mono<APIResponse<Report>> updateReportWithStatus(UUID reportId, ReportStatus reportStatus, String adminNotes) {
        return reportRepository.findById(reportId)
                .switchIfEmpty(Mono.error(new ReportNotFoundException("Report not found with ID: " + reportId)))
                .flatMap(report -> {
                    report.setStatus(reportStatus);
                    report.setAdminNotes(adminNotes);
                    report.setUpdatedAt(LocalDateTime.now());

                    if (reportStatus == ReportStatus.RESOLVED || reportStatus == ReportStatus.CLOSED) {
                        report.setResolvedAt(LocalDateTime.now());
                    }

                    return reportRepository.save(report);
                })
                .map(APIResponse::success)
                .onErrorResume(ReportNotFoundException.class,
                        error -> Mono.just(APIResponse.error(error.getMessage(), 404)));
    }

    public Mono<APIResponse<Long>> getReportCount() {
        return reportRepository.count()
                .map(APIResponse::success)
                .doOnSuccess(count -> log.debug("Total report count: {}", count.getData()))
                .onErrorReturn(APIResponse.error("Failed to get report count", 500));
    }

    public Mono<APIResponse<Long>> getNewReportCount() {
        return reportRepository.countByStatus(ReportStatus.NEW)
                .map(APIResponse::success)
                .doOnSuccess(count -> log.debug("New report count: {}", count.getData()))
                .onErrorReturn(APIResponse.error("Failed to get new report count", 500));
    }

    // Custom exception for better error handling
    public static class ReportNotFoundException extends RuntimeException {
        public ReportNotFoundException(String message) {
            super(message);
        }
    }
}
