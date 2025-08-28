package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.ReportSubmissionDTO;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.domain.models.Report;
import mk.ukim.finki.attendanceappserver.services.ReportService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.UUID;

@RestController
@RequestMapping("/reports")
@AllArgsConstructor
public class ReportController {

    private static final Logger LOGGER = LoggerFactory.getLogger(ReportController.class);

    private final ReportService reportService;

    @PostMapping("/submit")
    public Mono<APIResponse<UUID>> submitReport(@RequestBody ReportSubmissionDTO reportDTO) {
        LOGGER.info("Received request to submit report of status [{}] from student with info [{}]",
                reportDTO.getReportType(), reportDTO.getUserInfo());
        return reportService.submitReport(reportDTO);
    }

    @GetMapping("/all")
    public Mono<APIResponse<Flux<Report>>> getAllReports() {
        return reportService.getAllReports();
    }

    @GetMapping("/status/{status}")
    public Mono<APIResponse<Flux<Report>>> getReportsByStatus(@PathVariable String status) {
        return reportService.getReportsByStatus(status);
    }

    @GetMapping("/type/{reportType}")
    public Mono<APIResponse<Flux<Report>>> getReportsByType(@PathVariable String reportType) {
        return reportService.getReportsByType(reportType);
    }

    @PutMapping("/{reportId}/status")
    public Mono<APIResponse<Report>> updateReportStatus(
            @PathVariable UUID reportId,
            @RequestParam String status,
            @RequestParam(required = false) String adminNotes) {
        return reportService.updateReportStatus(reportId, status, adminNotes);
    }

    @GetMapping("/count")
    public Mono<APIResponse<Long>> getReportCount() {
        return reportService.getReportCount();
    }

    @GetMapping("/count/new")
    public Mono<APIResponse<Long>> getNewReportCount() {
        return reportService.getNewReportCount();
    }
}
