package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.AttendanceConfirmationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.AttendanceRegistrationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.db.CustomStudentAttendance;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;

import mk.ukim.finki.attendanceappserver.services.AttendanceService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/attendance")
@AllArgsConstructor
public class AttendanceController {

    private static final Logger LOGGER = LoggerFactory.getLogger(AttendanceController.class);

    private final AttendanceService attendanceService;

    @PostMapping("/register")
    public Mono<APIResponse<Integer>> registerAttendance(@RequestBody AttendanceRegistrationRequestDTO dto) {
        LOGGER.info("Request for registering attendance for student with ID [{}].", dto.getStudentIndex());
        return attendanceService.registerAttendance(dto)
                .map(APIResponse::success);
    }

    @PostMapping("/confirm")
    public Mono<APIResponse<Void>> confirmAttendance(@RequestBody AttendanceConfirmationRequestDTO dto) {
        LOGGER.info("Request for confirming attendance for attendance ID [{}].", dto.getAttendanceId());
        return attendanceService.confirmAttendance(dto)
                .then(Mono.just(APIResponse.<Void>success(null)));
    }

    @GetMapping(value = "/lecture/{lectureId}")
    public Mono<APIResponse<List<CustomStudentAttendance>>> getStudentAttendancesByLectureId(@PathVariable int lectureId) {
        LOGGER.info("Request for retrieving all student attendance for lecture with ID [{}]",
                lectureId);
        return attendanceService.getStudentAttendancesByProfessorClassSessionId(lectureId)
                .collectList()
                .map(APIResponse::success);
    }

    @GetMapping(value = "/{studentAttendanceId}")
    public Mono<APIResponse<CustomStudentAttendance>> getStudentAttendance(@PathVariable int studentAttendanceId) {
        LOGGER.info("Request for retrieving student attendance with ID [{}]",
                studentAttendanceId);
        return attendanceService.getStudentAttendanceById(studentAttendanceId)
                .map(APIResponse::success);
    }

    @GetMapping("/by-student/{studentIndex}/previous-30-days")
    public Mono<APIResponse<List<CustomStudentAttendance>>> getStudentAttendanceForStudentIndex(@PathVariable String studentIndex) {
        LOGGER.info("Request for retrieving student attendance for student index [{}] for the previous 30 days.", studentIndex);
        return attendanceService.getStudentAttendancesForStudentIndexForPrevious30Days(studentIndex)
                .collectList()
                .map(APIResponse::success);
    }
}
