package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.AttendanceRegistrationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.db.CustomStudentAttendance;
import mk.ukim.finki.attendanceappserver.repositories.StudentAttendanceRepository;
import mk.ukim.finki.attendanceappserver.repositories.StudentRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

import java.time.LocalDate;

@Service
@AllArgsConstructor
public class AttendanceService {

    private static final Logger LOGGER = LoggerFactory.getLogger(AttendanceService.class);

    private final StudentAttendanceRepository studentAttendanceRepository;
    private final StudentService studentService;

    public Mono<CustomStudentAttendance> getStudentAttendanceById(@NonNull int studentAttendanceId) {
        LOGGER.info("Retrieving student attendance with ID [{}]", studentAttendanceId);
        return studentAttendanceRepository.getStudentAttendanceById(studentAttendanceId);
    }

    public Flux<CustomStudentAttendance> getStudentAttendancesByProfessorClassSessionId(@NonNull int professorClassSessionId) {
        LOGGER.info("Retrieving all student attendance for professor class session with ID [{}] from database", professorClassSessionId);
        return studentAttendanceRepository.getStudentAttendanceByProfessorClassSessionId(professorClassSessionId);
    }

    public Flux<CustomStudentAttendance> getStudentAttendancesForStudentIndexForPrevious30Days(@NonNull String studentIndex) {
        var currentDate = LocalDate.now();
        var previousDate = currentDate.minusDays(30);
        LOGGER.info("Retrieving student attendance for student ID [{}] from date [{}] to date [{}]", studentIndex, previousDate, currentDate);
        return studentAttendanceRepository.getStudentAttendanceByStudentIndexFromDateToDate(studentIndex, previousDate, currentDate);
    }

    public Mono<String> registerAttendance(AttendanceRegistrationRequestDTO dto) {
        LOGGER.info("Registering attendance for student with index [{}] for professor class session with ID [{}]",
                dto.getStudentIndex(), dto.getProfessorClassSessionId());

        // Validation
        var isUniqueAttendance = studentAttendanceRepository.existsStudentAttendanceByStudentIndexAndProfessorClassSessionId(
                dto.getStudentIndex(),
                dto.getProfessorClassSessionId());
        var isStudentValid = studentService.isStudentValid(dto.getStudentIndex());

        return isUniqueAttendance
                .flatMap(isUnique -> {
                    if (isUnique) {
                        return Mono.error(new IllegalArgumentException("Attendance for already registered"));
                    }
                    return isStudentValid;
                })
                .flatMap(isValid -> {
                    if (!isValid) {
                        return Mono.error(new IllegalArgumentException("Student with Index [" + dto.getStudentIndex()
                                + "] is not valid or has no valid semester."));
                    }
                    studentAttendanceRepository.registerAttendance(dto.getStudentIndex(), dto.getProfessorClassSessionId(),
                            dto.getRegistrationTime());
                    return Mono.just("Attendance registered");
                });
    }

    // TODO: registerAttendance(AttendanceRegistrationRequest request):
    //       Find the Student and Lecture (or equivalent identifiers).
    //       Create a new Attendance record with a "pending" status.
    //       Save the Attendance record.

    // TODO: confirmAttendance(AttendanceConfirmationRequest request):
    //       Find the Attendance record by student and lecture (and status "pending").
    //       Update the Attendance record with the "present" status and the provided rssi value.
    //       Save the Attendance record.

    // TODO: getAttendanceByLecture(String lectureId): Retrieves attendance records for a given lecture (or combined lecture identifiers). Return a list of DTOs, not entities.
}
