package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationResponseDTO;
import mk.ukim.finki.attendanceappserver.dto.RoomProximityAnalyticsDTO;
import mk.ukim.finki.attendanceappserver.domain.repositories.ProximityVerificationRepository;
import mk.ukim.finki.attendanceappserver.domain.models.ProximityVerificationLog;
import mk.ukim.finki.attendanceappserver.services.shared.AttendanceUpdateService;
import mk.ukim.finki.attendanceappserver.services.shared.ProximityAnalysisService;

import org.springframework.stereotype.Service;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@AllArgsConstructor
public class ProximityVerificationService {

    private final ProximityVerificationRepository proximityVerificationRepository;
    private final ProximityAnalysisService proximityAnalysisService;
    private final AttendanceUpdateService attendanceUpdateService;

    /**
     * Process comprehensive BLE beacon proximity verification
     * Analyzes multiple proximity readings over verification period (10-30s)
     */
    public Mono<ProximityVerificationResponseDTO> processProximityVerification(ProximityVerificationRequestDTO request) {
        log.info("Processing proximity verification for student [{}] with {} detections",
                request.getStudentIndex(), request.getProximityDetections().size());

        return proximityAnalysisService.validateProximityRequest(request)
                .flatMap(valid -> proximityAnalysisService.analyzeProximityDetections(request))
                .flatMap(response -> attendanceUpdateService.updateAttendanceWithProximityResult(request, response))
                .flatMap(response -> attendanceUpdateService.logProximityVerificationSummary(request, response))
                .doOnSuccess(response -> log.info("Proximity verification completed for student [{}]: {}",
                        request.getStudentIndex(), response.getVerificationStatus()))
                .doOnError(error -> log.error("Proximity verification failed for student [{}]: {}",
                        request.getStudentIndex(), error.getMessage()));
    }

    /**
     * Get proximity analytics for a specific room
     */
    public Mono<RoomProximityAnalyticsDTO> getRoomProximityAnalytics(String roomId, LocalDateTime fromDate) {
        return Flux.merge(
                        proximityVerificationRepository.findByRoomIdAndDateRange(roomId, fromDate).collectList(),
                        proximityVerificationRepository.countSuccessfulVerificationsFromDate(fromDate),
                        proximityVerificationRepository.getAverageDistanceByRoomAndDateRange(roomId, fromDate)
                ).collectList()
                .map(results -> {
                    @SuppressWarnings("unchecked")
                    List<ProximityVerificationLog> logs = (List<ProximityVerificationLog>) results.get(0);
                    Long successCount = (Long) results.get(1);
                    Double avgDistance = (Double) results.get(2);

                    return RoomProximityAnalyticsDTO.builder()
                            .roomId(roomId)
                            .totalVerifications(logs.size())
                            .successfulVerifications(successCount.intValue())
                            .averageDistance(avgDistance != null ? avgDistance : 0.0)
                            .verificationLogs(logs)
                            .build();
                });
    }
}
