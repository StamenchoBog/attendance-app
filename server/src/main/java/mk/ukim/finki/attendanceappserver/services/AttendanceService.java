package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import mk.ukim.finki.attendanceappserver.domain.enums.AttendanceStatus;
import mk.ukim.finki.attendanceappserver.domain.models.ProfessorClassSession;
import mk.ukim.finki.attendanceappserver.dto.AttendanceConfirmationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.AttendanceRegistrationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.db.CustomStudentAttendance;
import mk.ukim.finki.attendanceappserver.dto.AttendanceSummaryDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationRequestDTO;
import mk.ukim.finki.attendanceappserver.domain.repositories.ClassSessionRepository;
import mk.ukim.finki.attendanceappserver.domain.repositories.StudentAttendanceRepository;
import mk.ukim.finki.attendanceappserver.domain.models.StudentAttendance;
import mk.ukim.finki.attendanceappserver.services.shared.ProximityAnalysisService;
import mk.ukim.finki.attendanceappserver.services.shared.AttendanceUpdateService;

import org.springframework.stereotype.Service;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Slf4j
@Service
@AllArgsConstructor
public class AttendanceService {

    private final StudentAttendanceRepository studentAttendanceRepository;
    private final ClassSessionRepository classSessionRepository;
    private final StudentService studentService;
    private final DeviceManagementService deviceManagementService;
    private final AttendanceUpdateService attendanceUpdateService;
    private final ProximityVerificationService proximityVerificationService;

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

        return validateStudentAndDevice(dto)
                .flatMap(valid -> findAndValidateSession(dto.getToken()))
                .flatMap(session -> handleAttendanceRecord(dto.getStudentIndex(), session.getId()))
                .flatMap(attendanceId -> handleProximityVerificationIfProvided(dto, attendanceId))
                .doOnSuccess(attendanceId -> log.info("Successfully registered attendance with ID [{}] for student [{}]",
                        attendanceId, dto.getStudentIndex()));
    }

    public Mono<Void> confirmAttendance(AttendanceConfirmationRequestDTO dto) {
        log.info("Confirming attendance for attendance record with ID [{}].", dto.getAttendanceId());

        return studentAttendanceRepository.findById(dto.getAttendanceId())
                .switchIfEmpty(Mono.error(new IllegalArgumentException("Attendance record not found.")))
                .flatMap(attendance -> {
                    if (attendance.getStatus() != AttendanceStatus.PENDING_VERIFICATION) {
                        return Mono.error(new IllegalStateException("Attendance is not pending verification."));
                    }
                    return attendanceUpdateService.updateAttendanceStatusForManualProximity(attendance, dto.getProximity());
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
                            Math.round(percentage * 100.0) / 100.0,
                            attendedClasses,
                            totalClasses,
                            absences
                    );
                })
                .defaultIfEmpty(new AttendanceSummaryDTO(0, 0, 0, 0));
    }

    // Private helper methods for attendance registration

    /**
     * Validates that the student exists and has an approved device
     */
    private Mono<Boolean> validateStudentAndDevice(AttendanceRegistrationRequestDTO dto) {
        return studentService.isStudentValid(dto.getStudentIndex())
                .flatMap(isValid -> {
                    if (Boolean.FALSE.equals(isValid)) {
                        return Mono.error(new IllegalArgumentException("Student is not valid or not enrolled in the current semester."));
                    }

                    return deviceManagementService.isDeviceApprovedForStudent(dto.getStudentIndex(), dto.getDeviceId())
                            .flatMap(isDeviceApproved -> {
                                if (Boolean.FALSE.equals(isDeviceApproved)) {
                                    return Mono.error(new IllegalArgumentException("DEVICE_NOT_REGISTERED"));
                                }
                                return Mono.just(true);
                            });
                });
    }

    /**
     * Finds a class session by attendance token and validates it's not expired
     */
    private Mono<ProfessorClassSession> findAndValidateSession(String token) {
        return classSessionRepository.findByAttendanceToken(token)
                .switchIfEmpty(Mono.error(new IllegalArgumentException("Invalid attendance token.")))
                .flatMap(session -> {
                    if (session.getTokenExpirationTime().isBefore(LocalDateTime.now())) {
                        return Mono.error(new IllegalArgumentException("Attendance token has expired."));
                    }
                    return Mono.just(session);
                });
    }

    /**
     * Handles the creation or update of an attendance record
     */
    private Mono<Integer> handleAttendanceRecord(String studentIndex, int sessionId) {
        return studentAttendanceRepository.existsStudentAttendanceByStudentIndexAndProfessorClassSessionId(
                        studentIndex, sessionId)
                .flatMap(exists -> {
                    if (Boolean.TRUE.equals(exists)) {
                        return updateExistingAttendanceRecord(studentIndex, sessionId);
                    } else {
                        return createAndSaveNewAttendanceRecord(studentIndex, sessionId);
                    }
                });
    }

    /**
     * Updates an existing attendance record
     */
    private Mono<Integer> updateExistingAttendanceRecord(String studentIndex, int sessionId) {
        log.info("Student [{}] already has an attendance record for session [{}]. Getting existing record.",
                studentIndex, sessionId);

        return studentAttendanceRepository.findByStudentIndexAndProfessorClassSessionId(studentIndex, sessionId)
                .flatMap(existingAttendance -> {
                    // Update the arrival time
                    existingAttendance.setArrivalTime(LocalDateTime.now());

                    // If the status is already verified, preserve it; otherwise, reset to pending
                    if (existingAttendance.getStatus() == AttendanceStatus.PRESENT ||
                            existingAttendance.getStatus() == AttendanceStatus.ABSENT) {
                        log.info("Preserving existing verified status [{}] for student [{}]",
                                existingAttendance.getStatus(), studentIndex);
                    } else {
                        existingAttendance.setStatus(AttendanceStatus.PENDING_VERIFICATION);
                        existingAttendance.setProximity(null);
                        log.info("Updating status to PENDING_VERIFICATION for student [{}]", studentIndex);
                    }

                    return studentAttendanceRepository.save(existingAttendance)
                            .map(StudentAttendance::getId);
                });
    }

    /**
     * Creates and saves a new attendance record
     */
    private Mono<Integer> createAndSaveNewAttendanceRecord(String studentIndex, int sessionId) {
        StudentAttendance newAttendance = createNewAttendanceRecord(studentIndex, sessionId);
        return studentAttendanceRepository.save(newAttendance)
                .map(StudentAttendance::getId);
    }

    /**
     * Creates a new attendance record with default values
     */
    private StudentAttendance createNewAttendanceRecord(String studentIndex, int sessionId) {
        return StudentAttendance.builder()
                .studentIndex(studentIndex)
                .professorClassSessionId(sessionId)
                .status(AttendanceStatus.PENDING_VERIFICATION)
                .arrivalTime(LocalDateTime.now())
                .build();
    }

    /**
     * Handles proximity verification if proximity data is provided during attendance registration
     * This automatically logs proximity verification and updates attendance status using the dedicated ProximityVerificationService
     */
    private Mono<Integer> handleProximityVerificationIfProvided(AttendanceRegistrationRequestDTO dto, Integer attendanceId) {
        // If no proximity data provided, just return the attendance ID
        if (dto.getProximityDetections() == null || dto.getProximityDetections().isEmpty()) {
            log.debug("No proximity verification data provided for student [{}], skipping proximity logging", dto.getStudentIndex());
            return Mono.just(attendanceId);
        }

        log.info("Processing proximity verification for student [{}] with {} detections during attendance registration",
                dto.getStudentIndex(), dto.getProximityDetections().size());

        // Create proximity verification request using the existing DTO structure
        ProximityVerificationRequestDTO proximityRequest = new ProximityVerificationRequestDTO();
        proximityRequest.setStudentIndex(dto.getStudentIndex());
        proximityRequest.setAttendanceId(attendanceId);
        proximityRequest.setProximityDetections(dto.getProximityDetections());
        proximityRequest.setExpectedRoomId(dto.getExpectedRoomId());
        proximityRequest.setVerificationDurationSeconds(dto.getVerificationDurationSeconds());

        return proximityVerificationService.processProximityVerification(proximityRequest)
                .doOnSuccess(response -> log.info("Proximity verification completed during attendance registration for student [{}]: {}",
                        dto.getStudentIndex(), response.getVerificationStatus()))
                .doOnError(error -> log.warn("Proximity verification failed during attendance registration for student [{}]: {}",
                        dto.getStudentIndex(), error.getMessage()))
                .then(Mono.just(attendanceId))
                .onErrorReturn(attendanceId);
    }
}
