package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import mk.ukim.finki.attendanceappserver.domain.enums.AttendanceStatus;
import mk.ukim.finki.attendanceappserver.dto.ProximityDetectionDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationResponseDTO;
import mk.ukim.finki.attendanceappserver.domain.repositories.ProximityVerificationRepository;
import mk.ukim.finki.attendanceappserver.domain.repositories.StudentAttendanceRepository;
import mk.ukim.finki.attendanceappserver.domain.repositories.ClassSessionRepository;
import mk.ukim.finki.attendanceappserver.domain.models.ProximityVerificationLog;
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
    private final StudentAttendanceRepository studentAttendanceRepository;
    private final ClassSessionRepository classSessionRepository;

    /**
     * Process comprehensive BLE beacon proximity verification
     * Analyzes multiple proximity readings over verification period (10-30s)
     */
    public Mono<ProximityVerificationResponseDTO> processProximityVerification(ProximityVerificationRequestDTO request) {
        log.info("Processing proximity verification for student [{}] with {} detections",
                request.getStudentIndex(), request.getProximityDetections().size());

        return validateRequest(request)
                .flatMap(valid -> analyzeProximityDetections(request))
                .flatMap(response -> updateAttendanceStatus(request, response))
                .flatMap(response -> logVerificationResults(request, response))
                .doOnSuccess(response -> log.info("Proximity verification completed for student [{}]: {}",
                        request.getStudentIndex(), response.getVerificationStatus()))
                .doOnError(error -> log.error("Proximity verification failed for student [{}]: {}",
                        request.getStudentIndex(), error.getMessage()));
    }

    /**
     * Log individual proximity detection during verification process
     */
    public Mono<Void> logProximityDetection(ProximityDetectionDTO detection) {
        log.debug("Logging proximity detection for student [{}]: {} at {}m",
                detection.getStudentIndex(), detection.getProximityLevel(), detection.getEstimatedDistance());

        ProximityVerificationLog logEntry = ProximityVerificationLog.builder()
                .studentIndex(detection.getStudentIndex())
                .beaconDeviceId(detection.getBeaconDeviceId())
                .detectedRoomId(detection.getDetectedRoomId())
                .rssi(detection.getRssi())
                .proximityLevel(detection.getProximityLevel())
                .estimatedDistance(detection.getEstimatedDistance())
                .verificationTimestamp(detection.getDetectionTimestamp())
                .verificationStatus("ONGOING")
                .beaconType(detection.getBeaconType())
                .sessionToken(detection.getSessionToken())
                .build();

        return proximityVerificationRepository.save(logEntry).then();
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

    private Mono<Boolean> validateRequest(ProximityVerificationRequestDTO request) {
        if (request.getProximityDetections() == null || request.getProximityDetections().isEmpty()) {
            return Mono.error(new IllegalArgumentException("No proximity detections provided"));
        }

        if (request.getVerificationDurationSeconds() == null ||
            request.getVerificationDurationSeconds() < 10 ||
            request.getVerificationDurationSeconds() > 60) {
            return Mono.error(new IllegalArgumentException("Invalid verification duration. Must be between 10-60 seconds"));
        }

        return Mono.just(true);
    }

    private Mono<ProximityVerificationResponseDTO> analyzeProximityDetections(ProximityVerificationRequestDTO request) {
        List<ProximityDetectionDTO> detections = request.getProximityDetections();

        // Calculate verification metrics
        long validDetections = detections.stream()
                .filter(d -> "NEAR".equals(d.getProximityLevel()) || "MEDIUM".equals(d.getProximityLevel()))
                .count();

        long wrongRoomDetections = detections.stream()
                .filter(d -> !request.getExpectedRoomId().equals(d.getDetectedRoomId()))
                .count();

        double averageDistance = detections.stream()
                .mapToDouble(ProximityDetectionDTO::getEstimatedDistance)
                .average()
                .orElse(Double.MAX_VALUE);

        boolean roomMismatch = wrongRoomDetections > 0;
        boolean insufficientProximity = validDetections < (detections.size() * 0.7); // 70% threshold
        boolean tooFar = averageDistance > 5.0; // 5 meter threshold

        // Determine verification result
        ProximityVerificationResponseDTO response = new ProximityVerificationResponseDTO();
        response.setTotalDetections(detections.size());
        response.setValidDetections((int) validDetections);
        response.setAverageDistance(averageDistance);
        response.setDetectedRoomId(detections.get(0).getDetectedRoomId());
        response.setExpectedRoomId(request.getExpectedRoomId());
        response.setVerificationStartTime(detections.get(0).getDetectionTimestamp());
        response.setVerificationEndTime(detections.get(detections.size() - 1).getDetectionTimestamp());

        if (roomMismatch) {
            response.setVerificationSuccess(false);
            response.setVerificationStatus("WRONG_ROOM");
            response.setFailureReason("Student detected in wrong classroom");
        } else if (insufficientProximity) {
            response.setVerificationSuccess(false);
            response.setVerificationStatus("FAILED");
            response.setFailureReason("Insufficient proximity readings during verification period");
        } else if (tooFar) {
            response.setVerificationSuccess(false);
            response.setVerificationStatus("FAILED");
            response.setFailureReason("Average distance too far from beacon");
        } else {
            response.setVerificationSuccess(true);
            response.setVerificationStatus("SUCCESS");
        }

        return Mono.just(response);
    }

    private Mono<ProximityVerificationResponseDTO> updateAttendanceStatus(
            ProximityVerificationRequestDTO request,
            ProximityVerificationResponseDTO response) {

        if (request.getAttendanceId() == null) {
            return Mono.just(response);
        }

        return studentAttendanceRepository.findById(request.getAttendanceId())
                .flatMap(attendance -> {
                    if (response.getVerificationSuccess()) {
                        attendance.setStatus(AttendanceStatus.PRESENT);
                        attendance.setProximity("VERIFIED_" + response.getAverageDistance().intValue() + "M");
                    } else {
                        attendance.setStatus(AttendanceStatus.ABSENT);
                        attendance.setProximity("FAILED_" + response.getVerificationStatus());
                    }
                    return studentAttendanceRepository.save(attendance);
                })
                .then(Mono.just(response))
                .onErrorReturn(response);
    }

    private Mono<ProximityVerificationResponseDTO> logVerificationResults(
            ProximityVerificationRequestDTO request,
            ProximityVerificationResponseDTO response) {

        // Create summary log entry for the entire verification process
        ProximityVerificationLog summaryLog = ProximityVerificationLog.builder()
                .studentAttendanceId(request.getAttendanceId())
                .studentIndex(request.getStudentIndex())
                .detectedRoomId(response.getDetectedRoomId())
                .expectedRoomId(response.getExpectedRoomId())
                .estimatedDistance(response.getAverageDistance())
                .verificationTimestamp(LocalDateTime.now())
                .verificationStatus(response.getVerificationStatus())
                .verificationDurationSeconds(request.getVerificationDurationSeconds())
                .sessionToken(request.getSessionToken())
                .build();

        return proximityVerificationRepository.save(summaryLog)
                .then(Mono.just(response));
    }

    // Inner DTO class for room analytics
    @lombok.Data
    @lombok.Builder
    public static class RoomProximityAnalyticsDTO {
        private String roomId;
        private Integer totalVerifications;
        private Integer successfulVerifications;
        private Double averageDistance;
        private List<ProximityVerificationLog> verificationLogs;
    }
}
