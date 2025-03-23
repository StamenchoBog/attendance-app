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
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/attendance")
@AllArgsConstructor
public class AttendanceController {

    private static final Logger LOGGER = LoggerFactory.getLogger(AttendanceController.class);

    private AttendanceService attendanceService;

    @GetMapping(value = "/{studentAttendanceId}")
    public Mono<APIResponse<CustomStudentAttendance>> getStudentAttendance(@PathVariable int studentAttendanceId) {
        LOGGER.info("Request for retrieving student attendance with ID [{}]",
                studentAttendanceId);
        return attendanceService.getStudentAttendanceById(studentAttendanceId)
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }

    @GetMapping("/register")
    public Mono<APIResponse<String>> registerAttendance(@RequestBody AttendanceRegistrationRequestDTO dto) {
        LOGGER.info("Request for registering attendance for student with ID [{}] and professor class session with ID [{}].",
                dto.getStudentIndex(), dto.getProfessorClassSessionId());
        return attendanceService.registerAttendance(dto)
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }

    @GetMapping(value = "/by-professor-class-session-id/{professorClassSessionId}")
    public Mono<APIResponse<List<CustomStudentAttendance>>> getStudentAttendancesByProfessorClassSessionID(@PathVariable int professorClassSessionId) {
        LOGGER.info("Request for retrieving all student attendance for professor class session with ID [{}]",
                professorClassSessionId);
        return attendanceService.getStudentAttendancesByProfessorClassSessionId(professorClassSessionId)
                .collectList()
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }

    @GetMapping("/by-student/{studentIndex}/previous-30-days")
    public Mono<APIResponse<List<CustomStudentAttendance>>> getStudentAttendanceForStudentIndex(@PathVariable String studentIndex) {
        LOGGER.info("Request for retrieving student attendance for student index [{}] for the previous 30 days.", studentIndex);
        return attendanceService.getStudentAttendancesForStudentIndexForPrevious30Days(studentIndex)
                .collectList()
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }

    // TODO: POST /attendance/confirm: Called by the mobile app after detecting the BLE beacon.
    //       Input: Student ID, QR code data (or lecture ID), RSSI value, timestamp.
    //       Output: Confirmation (e.g., a status code). This endpoint finalizes the attendance record.

    // TODO: GET /attendance/lecture/{lectureId}: Retrieves attendance records for a lecture.
    //       Input: Lecture ID.
    //       Output: List of attendance records (student IDs, timestamps, etc.).

}
