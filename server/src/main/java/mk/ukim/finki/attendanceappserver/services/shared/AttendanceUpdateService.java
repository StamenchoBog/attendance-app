package mk.ukim.finki.attendanceappserver.services.shared;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import mk.ukim.finki.attendanceappserver.domain.enums.AttendanceStatus;
import mk.ukim.finki.attendanceappserver.domain.enums.ProximityLevel;
import mk.ukim.finki.attendanceappserver.domain.enums.ProximityVerificationStatus;
import mk.ukim.finki.attendanceappserver.domain.models.ProximityVerificationLog;
import mk.ukim.finki.attendanceappserver.domain.models.StudentAttendance;
import mk.ukim.finki.attendanceappserver.domain.repositories.ProximityVerificationRepository;
import mk.ukim.finki.attendanceappserver.domain.repositories.StudentAttendanceRepository;
import mk.ukim.finki.attendanceappserver.dto.ProximityDetectionDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationResponseDTO;

import org.springframework.stereotype.Service;

import reactor.core.publisher.Mono;

import java.time.LocalDateTime;

/**
 * Shared service for attendance and logging operations to eliminate duplication
 * between AttendanceService and ProximityVerificationService
 */
@Slf4j
@Service
@AllArgsConstructor
public class AttendanceUpdateService {

    private final StudentAttendanceRepository studentAttendanceRepository;
    private final ProximityVerificationRepository proximityVerificationRepository;

    /**
     * Updates attendance status based on proximity verification results
     */
    public Mono<StudentAttendance> updateAttendanceStatus(StudentAttendance attendance,
                                                          ProximityVerificationResponseDTO response) {
        if (Boolean.TRUE.equals(response.getVerificationSuccess())) {
            attendance.setStatus(AttendanceStatus.PRESENT);
            attendance.setProximity(response.getAverageDistance() != null ? response.getAverageDistance().toString() : null);
        } else {
            attendance.setStatus(AttendanceStatus.ABSENT);
            attendance.setProximity(null);
        }
        return studentAttendanceRepository.save(attendance);
    }

    /**
     * Updates attendance status for manual proximity confirmation
     */
    public Mono<StudentAttendance> updateAttendanceStatusForManualProximity(StudentAttendance attendance, String proximity) {
        if ("NEAR".equals(proximity) || "MEDIUM".equals(proximity)) {
            attendance.setStatus(AttendanceStatus.PRESENT);
        } else {
            attendance.setStatus(AttendanceStatus.ABSENT);
        }
        attendance.setProximity(proximity);
        return studentAttendanceRepository.save(attendance);
    }

    /**
     * Updates attendance record with proximity verification result
     */
    public Mono<ProximityVerificationResponseDTO> updateAttendanceWithProximityResult(
            ProximityVerificationRequestDTO request,
            ProximityVerificationResponseDTO response) {

        if (request.getAttendanceId() == null) {
            return Mono.just(response);
        }

        return studentAttendanceRepository.findById(request.getAttendanceId())
                .flatMap(attendance -> updateAttendanceStatus(attendance, response))
                .then(Mono.just(response))
                .onErrorReturn(response);
    }

    /**
     * Logs individual proximity detection during verification
     */
    public Mono<Void> logProximityDetection(ProximityDetectionDTO detection, Integer attendanceId) {
        log.debug("Logging proximity detection for student [{}]: {} at {}m for attendance ID [{}]",
                detection.getStudentIndex(), detection.getProximityLevel(), detection.getEstimatedDistance(), attendanceId);

        ProximityVerificationLog logEntry = ProximityVerificationLog.builder()
                .studentAttendanceId(attendanceId)
                .studentIndex(detection.getStudentIndex())
                .beaconDeviceId(detection.getBeaconDeviceId())
                .detectedRoomId(detection.getDetectedRoomId())
                .rssi(detection.getRssi())
                .estimatedDistance(detection.getEstimatedDistance())
                .verificationTimestamp(detection.getDetectionTimestamp())
                .verificationStatus(ProximityVerificationStatus.ONGOING)
                .beaconType(detection.getBeaconType())
                .sessionToken(detection.getSessionToken())
                .build();

        return proximityVerificationRepository.save(logEntry).then();
    }

    /**
     * Logs proximity verification summary results
     */
    public Mono<ProximityVerificationResponseDTO> logProximityVerificationSummary(
            ProximityVerificationRequestDTO request,
            ProximityVerificationResponseDTO response) {

        ProximityVerificationLog summaryLog = ProximityVerificationLog.builder()
                .studentAttendanceId(request.getAttendanceId())
                .studentIndex(request.getStudentIndex())
                .detectedRoomId(response.getDetectedRoomId())
                .expectedRoomId(response.getExpectedRoomId())
                .estimatedDistance(response.getAverageDistance())
                .verificationTimestamp(LocalDateTime.now())
                .verificationDurationSeconds(request.getVerificationDurationSeconds())
                .sessionToken(request.getSessionToken())
                .rssi(request.getProximityDetections().getFirst().getRssi())
                .proximityLevel(ProximityLevel.valueOf(request.getProximityDetections().getFirst().getProximityLevel()))
                .verificationStatus(ProximityVerificationStatus.valueOf(response.getVerificationStatus()))
                .sessionToken(request.getSessionToken())
                // TODO: Add beacon_type and beacon_device_id
                .build();

        return proximityVerificationRepository.save(summaryLog).then(Mono.just(response));
    }
}
