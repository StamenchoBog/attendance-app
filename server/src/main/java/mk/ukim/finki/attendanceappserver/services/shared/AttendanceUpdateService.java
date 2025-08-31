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
            Double avgDistance = response.getAverageDistance();
            // Only store a valid proximity value
            if (avgDistance != null && avgDistance != Double.MAX_VALUE) {
                attendance.setProximity(avgDistance.toString());
                log.debug("Storing proximity value for attendance [{}]: {}", attendance.getId(), avgDistance);
            } else {
                attendance.setProximity(null);
                log.debug("No valid proximity value for attendance [{}]", attendance.getId());
            }
        } else {
            attendance.setStatus(AttendanceStatus.ABSENT);
            attendance.setProximity(null);
            log.debug("Attendance [{}] marked absent, no proximity value stored", attendance.getId());
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
        log.debug("Logging proximity detection for student [{}]: {} at {}m for attendance ID [{}], beaconType=[{}]",
                detection.getStudentIndex(), detection.getProximityLevel(), detection.getEstimatedDistance(), attendanceId, detection.getBeaconType());
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
        ProximityDetectionDTO firstDetection = request.getProximityDetections().getFirst();
        log.debug("Logging proximity summary for student [{}]: beaconType=[{}]",
                request.getStudentIndex(), firstDetection.getBeaconType());
        ProximityVerificationLog summaryLog = ProximityVerificationLog.builder()
                .studentAttendanceId(request.getAttendanceId())
                .studentIndex(request.getStudentIndex())
                .beaconDeviceId(firstDetection.getBeaconDeviceId())
                .detectedRoomId(response.getDetectedRoomId())
                .expectedRoomId(response.getExpectedRoomId())
                .estimatedDistance(response.getAverageDistance())
                .verificationTimestamp(LocalDateTime.now())
                .verificationDurationSeconds(request.getVerificationDurationSeconds())
                .sessionToken(request.getSessionToken())
                .rssi(firstDetection.getRssi())
                .proximityLevel(ProximityLevel.valueOf(firstDetection.getProximityLevel()))
                .verificationStatus(ProximityVerificationStatus.valueOf(response.getVerificationStatus()))
                .beaconType(firstDetection.getBeaconType())
                .build();
        return proximityVerificationRepository.save(summaryLog).then(Mono.just(response));
    }
}
