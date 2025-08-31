package mk.ukim.finki.attendanceappserver.services.shared;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import mk.ukim.finki.attendanceappserver.domain.enums.ProximityLevel;
import mk.ukim.finki.attendanceappserver.domain.enums.ProximityVerificationStatus;
import mk.ukim.finki.attendanceappserver.dto.ProximityDetectionDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationResponseDTO;
import mk.ukim.finki.attendanceappserver.util.ProximityConstants;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

import java.util.List;

/**
 * Shared service for proximity analysis logic to eliminate duplication
 * between AttendanceService and ProximityVerificationService
 */
@Slf4j
@Service
@AllArgsConstructor
public class ProximityAnalysisService {

    /**
    private final AttendanceUpdateService attendanceUpdateService;

     * Analyzes proximity detections and returns verification response
     */
    public Mono<ProximityVerificationResponseDTO> analyzeProximityDetections(ProximityVerificationRequestDTO request) {
        List<ProximityDetectionDTO> detections = request.getProximityDetections();

        if (detections.isEmpty()) {
            return Mono.error(new IllegalArgumentException("No proximity detections provided"));
        }

        // Calculate verification metrics
        long validDetections = countValidDetections(detections);
        long idealDetections = countIdealDetections(detections);
        long wrongRoomDetections = countWrongRoomDetections(detections, request.getExpectedRoomId());
        long outOfRangeDetections = countOutOfRangeDetections(detections);
        double averageDistance = calculateAverageDistance(detections);

        // Evaluate verification conditions
        VerificationResult result = evaluateVerification(
            detections.size(), validDetections, idealDetections, wrongRoomDetections,
            outOfRangeDetections, averageDistance);

        return Mono.just(buildVerificationResponse(detections, request, result, averageDistance, validDetections));
    }

    /**
     * Validates proximity verification request
     */
    public Mono<Boolean> validateProximityRequest(ProximityVerificationRequestDTO request) {
        if (request.getProximityDetections() == null || request.getProximityDetections().isEmpty()) {
            return Mono.error(new IllegalArgumentException("No proximity detections provided"));
        }

        if (request.getVerificationDurationSeconds() != null &&
            (request.getVerificationDurationSeconds() < ProximityConstants.MIN_VERIFICATION_DURATION ||
             request.getVerificationDurationSeconds() > ProximityConstants.MAX_VERIFICATION_DURATION)) {
            return Mono.error(new IllegalArgumentException(
                String.format("Invalid verification duration. Must be between %d-%d seconds",
                    ProximityConstants.MIN_VERIFICATION_DURATION, ProximityConstants.MAX_VERIFICATION_DURATION)));
        }
        return Mono.just(true);
    }

    /**
     * Counts detections within acceptable range (NEAR, MEDIUM, FAR)
     * Excludes OUT_OF_RANGE detections
     */
    private long countValidDetections(List<ProximityDetectionDTO> detections) {
        return detections.stream()
                .filter(d -> ProximityLevel.NEAR.name().equals(d.getProximityLevel()) ||
                           ProximityLevel.MEDIUM.name().equals(d.getProximityLevel()) ||
                           ProximityLevel.FAR.name().equals(d.getProximityLevel()))
                .count();
    }

    /**
     * Counts detections in ideal range (NEAR, MEDIUM)
     * These are preferred for attendance verification
     */
    private long countIdealDetections(List<ProximityDetectionDTO> detections) {
        return detections.stream()
                .filter(d -> ProximityLevel.NEAR.name().equals(d.getProximityLevel()) ||
                           ProximityLevel.MEDIUM.name().equals(d.getProximityLevel()))
                .count();
    }

    /**
     * Counts detections that are out of reasonable classroom range
     */
    private long countOutOfRangeDetections(List<ProximityDetectionDTO> detections) {
        return detections.stream()
                .filter(d -> ProximityLevel.OUT_OF_RANGE.name().equals(d.getProximityLevel()))
                .count();
    }

    private long countWrongRoomDetections(List<ProximityDetectionDTO> detections, String expectedRoomId) {
        return detections.stream()
                .filter(d -> !expectedRoomId.equals(d.getDetectedRoomId()))
                .count();
    }

    private double calculateAverageDistance(List<ProximityDetectionDTO> detections) {
        return detections.stream()
                .mapToDouble(ProximityDetectionDTO::getEstimatedDistance)
                .average()
                .orElse(Double.MAX_VALUE);
    }

    /**
     * Enhanced verification logic that considers all proximity levels
     */
    private VerificationResult evaluateVerification(int totalDetections, long validDetections,
                                                  long idealDetections, long wrongRoomDetections,
                                                  long outOfRangeDetections, double averageDistance) {

        // Check for wrong room first
        if (wrongRoomDetections > 0) {
            return new VerificationResult(false, ProximityVerificationStatus.WRONG_ROOM, "Student detected in wrong classroom");
        }

        // Check if too many out of range detections
        double outOfRangeRatio = (double) outOfRangeDetections / totalDetections;
        if (outOfRangeRatio > ProximityConstants.OUT_OF_RANGE_THRESHOLD) {
            return new VerificationResult(false, ProximityVerificationStatus.FAILED, "Too many out-of-range detections - student likely not in classroom");
        }

        // Check if sufficient valid detections
        double validRatio = (double) validDetections / totalDetections;
        if (validRatio < ProximityConstants.PROXIMITY_SUCCESS_THRESHOLD) {
            return new VerificationResult(false, ProximityVerificationStatus.FAILED, "Insufficient proximity readings during verification period");
        }

        // Check average distance - allow up to configured maximum for large lecture halls
        if (averageDistance > ProximityConstants.MAX_DISTANCE_THRESHOLD) {
            return new VerificationResult(false, ProximityVerificationStatus.FAILED, "Average distance too far from beacon");
        }

        // Determine success level based on proximity quality
        double idealRatio = (double) idealDetections / totalDetections;
        if (idealRatio >= ProximityConstants.IDEAL_RATIO_THRESHOLD) {
            return new VerificationResult(true, ProximityVerificationStatus.SUCCESS, null);
        } else {
            // Still successful but with lower confidence (mostly FAR detections)
            return new VerificationResult(true, ProximityVerificationStatus.SUCCESS_LOW_CONFIDENCE, "Verified but mostly at far range");
        }
    }

    private ProximityVerificationResponseDTO buildVerificationResponse(
            List<ProximityDetectionDTO> detections,
            ProximityVerificationRequestDTO request,
            VerificationResult result,
            double averageDistance,
            long validDetections) {

        ProximityVerificationResponseDTO response = new ProximityVerificationResponseDTO();
        response.setTotalDetections(detections.size());
        response.setValidDetections((int) validDetections);
        response.setAverageDistance(averageDistance);
        response.setDetectedRoomId(detections.getFirst().getDetectedRoomId());
        response.setExpectedRoomId(request.getExpectedRoomId());
        response.setVerificationStartTime(detections.getFirst().getDetectionTimestamp());
        response.setVerificationEndTime(detections.getLast().getDetectionTimestamp());
        response.setVerificationSuccess(result.success);
        response.setVerificationStatus(result.status.name());
        response.setFailureReason(result.failureReason);

        return response;
    }

    private record VerificationResult(boolean success, ProximityVerificationStatus status, String failureReason) {}
}
