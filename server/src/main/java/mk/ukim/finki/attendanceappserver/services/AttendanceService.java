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
import mk.ukim.finki.attendanceappserver.services.shared.AttendanceUpdateService;
import mk.ukim.finki.attendanceappserver.exceptions.AttendanceException;

import org.springframework.stereotype.Service;

import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Objects;

@Slf4j
@Service
@AllArgsConstructor
public class AttendanceService {

    private static final int DEFAULT_DAYS_LOOKBACK = 30;
    private static final int PERCENTAGE_SCALE_FACTOR = 100;

    private final StudentAttendanceRepository studentAttendanceRepository;
    private final ClassSessionRepository classSessionRepository;
    private final StudentService studentService;
    private final DeviceManagementService deviceManagementService;
    private final AttendanceUpdateService attendanceUpdateService;
    private final ProximityVerificationService proximityVerificationService;

    /**
     * Retrieves a student attendance record by its ID
     *
     * @param studentAttendanceId The ID of the student attendance record to retrieve
     * @return A Mono containing the student attendance record, if found
     */
    public Mono<CustomStudentAttendance> getStudentAttendanceById(@NonNull int studentAttendanceId) {
        log.info("Retrieving student attendance with ID [{}]", studentAttendanceId);
        return studentAttendanceRepository.getStudentAttendanceById(studentAttendanceId);
    }

    /**
     * Retrieves all student attendance records for a specific class session
     *
     * @param professorClassSessionId The ID of the professor class session
     * @return A Flux of student attendance records for the specified class session
     */
    public Flux<CustomStudentAttendance> getStudentAttendancesByProfessorClassSessionId(@NonNull int professorClassSessionId) {
        log.info("Retrieving all student attendance for professor class session with ID [{}] from database", professorClassSessionId);
        return studentAttendanceRepository.getStudentAttendanceByProfessorClassSessionId(professorClassSessionId);
    }

    /**
     * Retrieves student attendance records for a student for the previous 30 days
     *
     * @param studentIndex The index of the student
     * @return A Flux of student attendance records for the specified student within the last 30 days
     */
    public Flux<CustomStudentAttendance> getStudentAttendancesForStudentIndexForPrevious30Days(@NonNull String studentIndex) {
        LocalDate currentDate = LocalDate.now();
        LocalDate previousDate = currentDate.minusDays(DEFAULT_DAYS_LOOKBACK);
        log.info("Retrieving student attendance for student ID [{}] from date [{}] to date [{}]",
                studentIndex, previousDate, currentDate);

        return studentAttendanceRepository.getStudentAttendanceByStudentIndexFromDateToDate(
                studentIndex, previousDate, currentDate);
    }

    /**
     * Registers attendance for a student
     *
     * @param dto The attendance registration request data
     * @return A Mono containing the ID of the registered attendance record
     */
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

    /**
     * Confirms an attendance record
     *
     * @param dto The attendance confirmation request data
     * @return A Mono that completes when the attendance is confirmed
     */
    public Mono<Void> confirmAttendance(AttendanceConfirmationRequestDTO dto) {
        log.info("Confirming attendance for attendance record with ID [{}].", dto.getAttendanceId());

        return studentAttendanceRepository.findById(dto.getAttendanceId())
                .switchIfEmpty(Mono.error(new AttendanceException("Attendance record not found.")))
                .flatMap(attendance -> {
                    if (attendance.getStatus() != AttendanceStatus.PENDING_VERIFICATION) {
                        return Mono.error(new AttendanceException("Attendance is not pending verification."));
                    }
                    return attendanceUpdateService.updateAttendanceStatusForManualProximity(attendance, dto.getProximity());
                }).then();
    }

    /**
     * Calculates attendance summary for a student for a specific semester
     *
     * @param studentIndex The index of the student
     * @param semester The semester for which to calculate the summary
     * @return A Mono containing the attendance summary
     */
    public Mono<AttendanceSummaryDTO> getAttendanceSummary(String studentIndex, String semester) {
        log.info("Calculating attendance summary for student [{}] for semester [{}]", studentIndex, semester);

        return studentAttendanceRepository.findAttendanceSummaryByStudentIndexAndSemester(studentIndex, semester)
                .map(summary -> {
                    int totalClasses = Objects.requireNonNullElse(summary.getTotal_classes(), 0);
                    int attendedClasses = Objects.requireNonNullElse(summary.getAttended_classes(), 0);
                    double percentage = calculateAttendancePercentage(attendedClasses, totalClasses);
                    int absences = totalClasses - attendedClasses;

                    return new AttendanceSummaryDTO(
                            Math.round(percentage * PERCENTAGE_SCALE_FACTOR) / PERCENTAGE_SCALE_FACTOR,
                            attendedClasses,
                            totalClasses,
                            absences
                    );
                })
                .defaultIfEmpty(createDefaultAttendanceSummary());
    }

    // Private helper methods for attendance registration

    /**
     * Validates that the student exists and has an approved device
     *
     * @param dto The attendance registration request data
     * @return A Mono that completes if validation is successful
     */
    private Mono<Boolean> validateStudentAndDevice(AttendanceRegistrationRequestDTO dto) {
        return studentService.isStudentValid(dto.getStudentIndex())
                .flatMap(isValid -> {
                    if (Boolean.FALSE.equals(isValid)) {
                        return Mono.error(new AttendanceException("Student is not valid or not enrolled in the current semester."));
                    }

                    return deviceManagementService.isDeviceApprovedForStudent(dto.getStudentIndex(), dto.getDeviceId())
                            .flatMap(isDeviceApproved -> {
                                if (Boolean.FALSE.equals(isDeviceApproved)) {
                                    return Mono.error(new AttendanceException("DEVICE_NOT_REGISTERED"));
                                }
                                return Mono.just(true);
                            });
                });
    }

    /**
     * Finds a class session by attendance token and validates it's not expired
     *
     * @param token The attendance token
     * @return A Mono containing the class session if found and valid
     */
    private Mono<ProfessorClassSession> findAndValidateSession(String token) {
        return classSessionRepository.findByAttendanceToken(token)
                .switchIfEmpty(Mono.error(new AttendanceException("Invalid attendance token.")))
                .flatMap(session -> {
                    if (session.getTokenExpirationTime().isBefore(LocalDateTime.now())) {
                        return Mono.error(new AttendanceException("Attendance token has expired."));
                    }
                    return Mono.just(session);
                });
    }

    /**
     * Handles the creation or update of an attendance record
     *
     * @param studentIndex The index of the student
     * @param sessionId The ID of the class session
     * @return A Mono containing the ID of the attendance record
     */
    private Mono<Integer> handleAttendanceRecord(String studentIndex, int sessionId) {
        return studentAttendanceRepository.existsStudentAttendanceByStudentIndexAndProfessorClassSessionId(
                        studentIndex, sessionId)
                .flatMap(exists ->
                    Boolean.TRUE.equals(exists)
                        ? updateExistingAttendanceRecord(studentIndex, sessionId)
                        : createAndSaveNewAttendanceRecord(studentIndex, sessionId)
                );
    }

    /**
     * Updates an existing attendance record
     *
     * @param studentIndex The index of the student
     * @param sessionId The ID of the class session
     * @return A Mono containing the ID of the updated attendance record
     */
    private Mono<Integer> updateExistingAttendanceRecord(String studentIndex, int sessionId) {
        log.info("Student [{}] already has an attendance record for session [{}]. Getting existing record.",
                studentIndex, sessionId);

        return studentAttendanceRepository.findByStudentIndexAndProfessorClassSessionId(studentIndex, sessionId)
                .flatMap(existingAttendance -> {
                    // Update the arrival time
                    existingAttendance.setArrivalTime(LocalDateTime.now());

                    // If the status is already verified, preserve it; otherwise, reset to pending
                    if (isStatusVerified(existingAttendance.getStatus())) {
                        log.info("Preserving existing verified status [{}] for student [{}]",
                                existingAttendance.getStatus(), studentIndex);
                    } else {
                        resetAttendanceStatusToPending(existingAttendance);
                        log.info("Updating status to PENDING_VERIFICATION for student [{}]", studentIndex);
                    }

                    return studentAttendanceRepository.save(existingAttendance)
                            .map(StudentAttendance::getId);
                });
    }

    /**
     * Checks if the attendance status is verified
     *
     * @param status The attendance status to check
     * @return true if the status is verified, false otherwise
     */
    private boolean isStatusVerified(AttendanceStatus status) {
        return status == AttendanceStatus.PRESENT || status == AttendanceStatus.ABSENT;
    }

    /**
     * Resets the attendance status to pending verification
     *
     * @param attendance The attendance record to reset
     */
    private void resetAttendanceStatusToPending(StudentAttendance attendance) {
        attendance.setStatus(AttendanceStatus.PENDING_VERIFICATION);
        attendance.setProximity(null);
    }

    /**
     * Creates and saves a new attendance record
     *
     * @param studentIndex The index of the student
     * @param sessionId The ID of the class session
     * @return A Mono containing the ID of the new attendance record
     */
    private Mono<Integer> createAndSaveNewAttendanceRecord(String studentIndex, int sessionId) {
        StudentAttendance newAttendance = createNewAttendanceRecord(studentIndex, sessionId);
        return studentAttendanceRepository.save(newAttendance)
                .map(StudentAttendance::getId);
    }

    /**
     * Creates a new attendance record with default values
     *
     * @param studentIndex The index of the student
     * @param sessionId The ID of the class session
     * @return A new attendance record
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
     *
     * @param dto The attendance registration request data
     * @param attendanceId The ID of the attendance record
     * @return A Mono containing the ID of the attendance record
     */
    private Mono<Integer> handleProximityVerificationIfProvided(AttendanceRegistrationRequestDTO dto, Integer attendanceId) {
        // If no proximity data provided, just return the attendance ID
        if (dto.getProximityDetections() == null || dto.getProximityDetections().isEmpty()) {
            log.debug("No proximity verification data provided for student [{}], skipping proximity logging", dto.getStudentIndex());
            return Mono.just(attendanceId);
        }

        log.info("Processing proximity verification for student [{}] with {} detections during attendance registration",
                dto.getStudentIndex(), dto.getProximityDetections().size());

        var proximityRequest = buildProximityVerificationRequest(dto, attendanceId);

        return proximityVerificationService.processProximityVerification(proximityRequest)
                .doOnSuccess(response -> log.info("Proximity verification completed during attendance registration for student [{}]: {}",
                        dto.getStudentIndex(), response.getVerificationStatus()))
                .doOnError(error -> log.warn("Proximity verification failed during attendance registration for student [{}]: {}",
                        dto.getStudentIndex(), error.getMessage()))
                .then(Mono.just(attendanceId))
                .onErrorReturn(attendanceId);
    }

    /**
     * Builds a proximity verification request
     *
     * @param dto The attendance registration request data
     * @param attendanceId The ID of the attendance record
     * @return A proximity verification request
     */
    private ProximityVerificationRequestDTO buildProximityVerificationRequest(
            AttendanceRegistrationRequestDTO dto, Integer attendanceId) {
        return ProximityVerificationRequestDTO.builder()
                .studentIndex(dto.getStudentIndex())
                .attendanceId(attendanceId)
                .proximityDetections(dto.getProximityDetections())
                .expectedRoomId(dto.getExpectedRoomId())
                .verificationDurationSeconds(dto.getVerificationDurationSeconds())
                .sessionToken(dto.getToken())
                .build();
    }

    /**
     * Calculates the attendance percentage
     *
     * @param attendedClasses The number of attended classes
     * @param totalClasses The total number of classes
     * @return The attendance percentage
     */
    private double calculateAttendancePercentage(int attendedClasses, int totalClasses) {
        return totalClasses > 0 ? ((double) attendedClasses / totalClasses) * 100 : 0.0;
    }

    /**
     * Creates a default attendance summary with zero values
     *
     * @return A default attendance summary
     */
    private AttendanceSummaryDTO createDefaultAttendanceSummary() {
        return new AttendanceSummaryDTO(0, 0, 0, 0);
    }
}
