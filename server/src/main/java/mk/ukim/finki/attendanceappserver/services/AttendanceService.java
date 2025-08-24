package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import mk.ukim.finki.attendanceappserver.domain.enums.AttendanceStatus;
import mk.ukim.finki.attendanceappserver.dto.AttendanceConfirmationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.AttendanceRegistrationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.db.CustomStudentAttendance;
import mk.ukim.finki.attendanceappserver.repositories.ClassSessionRepository;
import mk.ukim.finki.attendanceappserver.repositories.StudentAttendanceRepository;
import mk.ukim.finki.attendanceappserver.repositories.models.StudentAttendance;
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
        log.info("Registering attendance for student with index [{}] with token [{}].",
                dto.getStudentIndex(), dto.getToken());

        return studentService.isStudentValid(dto.getStudentIndex())
                .flatMap(isValid -> {
                    if (!isValid) {
                        return Mono.error(new IllegalArgumentException("Student is not valid or not enrolled in the current semester."));
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
                                            if (exists) {
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

}
