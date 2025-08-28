package mk.ukim.finki.attendanceappserver.domain.repositories;

import mk.ukim.finki.attendanceappserver.domain.enums.ReportPriority;
import mk.ukim.finki.attendanceappserver.domain.enums.ReportStatus;
import mk.ukim.finki.attendanceappserver.domain.enums.ReportType;
import mk.ukim.finki.attendanceappserver.domain.models.Report;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.UUID;

@Repository
public interface ReportRepository extends R2dbcRepository<Report, UUID> {

    Flux<Report> findByStatusOrderByCreatedAtDesc(ReportStatus status);

    Flux<Report> findByReportTypeOrderByCreatedAtDesc(ReportType reportType);

    Flux<Report> findByPriorityOrderByCreatedAtDesc(ReportPriority priority);

    Flux<Report> findByCreatedAtBetweenOrderByCreatedAtDesc(LocalDateTime start, LocalDateTime end);

    Mono<Long> countByStatus(ReportStatus status);

    Mono<Long> countByReportType(ReportType reportType);
}
