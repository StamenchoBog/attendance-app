package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import mk.ukim.finki.attendanceappserver.domain.enums.AttendanceStatus;
import mk.ukim.finki.attendanceappserver.dto.AttendanceConfirmationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.AttendanceRegistrationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.db.CustomStudentAttendance;
import mk.ukim.finki.attendanceappserver.dto.AttendanceSummaryDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityDetectionDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationResponseDTO;
import mk.ukim.finki.attendanceappserver.domain.repositories.ClassSessionRepository;
import mk.ukim.finki.attendanceappserver.domain.repositories.StudentAttendanceRepository;
import mk.ukim.finki.attendanceappserver.domain.repositories.ProximityVerificationRepository;
import mk.ukim.finki.attendanceappserver.domain.models.StudentAttendance;
import mk.ukim.finki.attendanceappserver.domain.models.ProximityVerificationLog;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@AllArgsConstructor
public class AttendanceService {

    private final StudentAttendanceRepository studentAttendanceRepository;
    private final ClassSessionRepository classSessionRepository;
    private final StudentService studentService;
    private final DeviceManagementService deviceManagementService;
    private final ProximityVerificationRepository proximityVerificationRepository;

    public Mono<CustomStudentAttendance> getStudentAttendanceById(@NonNull int studentAttendanceId) {
        log.info("Retrieving student attendance with ID [{}]", studentAttendanceId);
        return studentAttendanceRepository.getStudentAttendanceById(studentAttendanceId);
    }

    public Flux<CustomStudentAttendance> getStudentAttendancesByProfessorClassSessionId(@NonNull int professorClassSessionId) {
        log.info("Retrieving all student attendance for professor class session with ID [{}] from database", professorClassSessionId);
        return studentAttendanceRepository.getStudentAttendanceByProfessorClassSessionId(professorClassSessionId);
    }

    public Flux<CustomStudentAttendance> getStudentAttendancesForStudentIndexForPrevious30Days(@NonNull String studentIndex) {
        var currentDate = LocalDate.now();
        var previousDate = currentDate.minusDays(30);
        log.info("Retrieving student attendance for student ID [{}] from date [{}] to date [{}]", studentIndex, previousDate, currentDate);
        return studentAttendanceRepository.getStudentAttendanceByStudentIndexFromDateToDate(studentIndex, previousDate, currentDate);
    }

    public Mono<Integer> registerAttendance(AttendanceRegistrationRequestDTO dto) {
        log.info("Registering attendance for student with index [{}] with token [{}] from device [{}].",
                dto.getStudentIndex(), dto.getToken(), dto.getDeviceId());

        return studentService.isStudentValid(dto.getStudentIndex())
                .flatMap(isValid -> {
                    if (Boolean.FALSE.equals(isValid)) {
                        return Mono.error(new IllegalArgumentException("Student is not valid or not enrolled in the current semester."));
                    }
                    
                    // Verify device is registered and approved for this student
                    return deviceManagementService.isDeviceApprovedForStudent(dto.getStudentIndex(), dto.getDeviceId())
                            .flatMap(isDeviceApproved -> {
                                if (Boolean.FALSE.equals(isDeviceApproved)) {
                                    return Mono.error(new IllegalArgumentException("DEVICE_NOT_REGISTERED"));
                                }
                                
                                return classSessionRepository.findByAttendanceToken(dto.getToken())
                                        .switchIfEmpty(Mono.error(new IllegalArgumentException("Invalid attendance token.")))
                                        .flatMap(session -> {
                                            if (session.getTokenExpirationTime().isBefore(LocalDateTime.now())) {
                                                return Mono.error(new IllegalArgumentException("Attendance token has expired."));
                                            }

                                            return studentAttendanceRepository.existsStudentAttendanceByStudentIndexAndProfessorClassSessionId(
                                                    dto.getStudentIndex(), session.getId())
                                                    .flatMap(exists -> {
                                                        if (Boolean.TRUE.equals(exists)) {
                                                            return Mono.error(new IllegalArgumentException("Attendance already registered for this session."));
                                                        }

                                                        StudentAttendance newAttendance = StudentAttendance.builder()
                                                                .studentIndex(dto.getStudentIndex())
                                                                .professorClassSessionId(session.getId())
                                                                .status(AttendanceStatus.PENDING_VERIFICATION)
                                                                .arrivalTime(LocalDateTime.now())
                                                                .build();

                                                        return studentAttendanceRepository.save(newAttendance)
                                                                .map(StudentAttendance::getId);
                                                    });
                                        });
                            });
                });
    }

    public Mono<Void> confirmAttendance(AttendanceConfirmationRequestDTO dto) {
        log.info("Confirming attendance for attendance record with ID [{}].", dto.getAttendanceId());

        return studentAttendanceRepository.findById(dto.getAttendanceId())
                .switchIfEmpty(Mono.error(new IllegalArgumentException("Attendance record not found.")))
                .flatMap(attendance -> {
                    if (attendance.getStatus() != AttendanceStatus.PENDING_VERIFICATION) {
                        return Mono.error(new IllegalStateException("Attendance is not pending verification."));
                    }

                    if ("NEAR".equals(dto.getProximity()) || "MEDIUM".equals(dto.getProximity())) {
                        attendance.setStatus(AttendanceStatus.PRESENT);
                    } else {
                        attendance.setStatus(AttendanceStatus.ABSENT);
                    }
                    attendance.setProximity(dto.getProximity());
                    return studentAttendanceRepository.save(attendance);
                }).then();
    }

    public Mono<AttendanceSummaryDTO> getAttendanceSummary(String studentIndex, String semester) {
        log.info("Calculating attendance summary for student [{}] for semester [{}]", studentIndex, semester);
        return studentAttendanceRepository.findAttendanceSummaryByStudentIndexAndSemester(studentIndex, semester)
                .map(summary -> {
                    int totalClasses = summary.getTotal_classes() != null ? summary.getTotal_classes() : 0;
                    int attendedClasses = summary.getAttended_classes() != null ? summary.getAttended_classes() : 0;
                    double percentage = (totalClasses > 0) ? ((double) attendedClasses / totalClasses) * 100 : 0.0;
                    int absences = totalClasses - attendedClasses;

                    return new AttendanceSummaryDTO(
                            Math.round(percentage * 100.0) / 100.0, // Round to two decimal places
                            attendedClasses,
                            totalClasses,
                            absences
                    );
                })
                .defaultIfEmpty(new AttendanceSummaryDTO(0, 0, 0, 0));
    }

    /**
     * Enhanced proximity verification for BLE beacon system
     */
    public Mono<ProximityVerificationResponseDTO> verifyProximityWithBeacon(ProximityVerificationRequestDTO request) {
        log.info("Processing BLE beacon proximity verification for student [{}] with {} detections",
                request.getStudentIndex(), request.getProximityDetections().size());

        return validateProximityRequest(request)
                .flatMap(valid -> analyzeProximityDetections(request))
                .flatMap(response -> updateAttendanceWithProximityResult(request, response))
                .flatMap(response -> logProximityVerificationSummary(request, response))
                .doOnSuccess(response -> log.info("BLE proximity verification completed for student [{}]: {}",
                        request.getStudentIndex(), response.getVerificationStatus()));
    }

    /**
     * Log individual proximity detection during verification
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

    private Mono<Boolean> validateProximityRequest(ProximityVerificationRequestDTO request) {
        if (request.getProximityDetections() == null || request.getProximityDetections().isEmpty()) {
            return Mono.error(new IllegalArgumentException("No proximity detections provided"));
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

        // Build response
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

    private Mono<ProximityVerificationResponseDTO> updateAttendanceWithProximityResult(
            ProximityVerificationRequestDTO request,
            ProximityVerificationResponseDTO response) {

        if (request.getAttendanceId() == null) {
            return Mono.just(response);
        }

        return studentAttendanceRepository.findById(request.getAttendanceId())
                .flatMap(attendance -> {
                    if (response.getVerificationSuccess()) {
                        attendance.setStatus(AttendanceStatus.PRESENT);
                        attendance.setProximity("BEACON_VERIFIED_" + response.getAverageDistance().intValue() + "M");
                    } else {
                        attendance.setStatus(AttendanceStatus.ABSENT);
                        attendance.setProximity("BEACON_FAILED_" + response.getVerificationStatus());
                    }
                    return studentAttendanceRepository.save(attendance);
                })
                .then(Mono.just(response))
                .onErrorReturn(response);
    }

    private Mono<ProximityVerificationResponseDTO> logProximityVerificationSummary(
            ProximityVerificationRequestDTO request,
            ProximityVerificationResponseDTO response) {

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
}
