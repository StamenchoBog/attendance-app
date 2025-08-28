package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.AttendanceConfirmationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.AttendanceRegistrationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityDetectionDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.ProximityVerificationResponseDTO;
import mk.ukim.finki.attendanceappserver.dto.db.CustomStudentAttendance;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.services.AttendanceService;
import mk.ukim.finki.attendanceappserver.services.ProximityVerificationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/attendance")
@AllArgsConstructor
public class AttendanceController {

    private static final Logger LOGGER = LoggerFactory.getLogger(AttendanceController.class);

    private final AttendanceService attendanceService;
    private final ProximityVerificationService proximityVerificationService;

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

    // ENHANCED BLE BEACON ENDPOINTS WITH LOGGING

    /**
     * Comprehensive BLE beacon proximity verification endpoint
     * Processes multiple proximity readings collected during 10-30s verification period
     */
    @PostMapping("/verify-proximity")
    public Mono<APIResponse<ProximityVerificationResponseDTO>> verifyProximity(@RequestBody ProximityVerificationRequestDTO dto) {
        LOGGER.info("Request for comprehensive proximity verification for student [{}] with {} detections",
                dto.getStudentIndex(), dto.getProximityDetections().size());
        return attendanceService.verifyProximityWithBeacon(dto)
                .map(APIResponse::success);
    }

    /**
     * Log individual proximity detection during real-time verification
     * Called by mobile app every few seconds during verification process
     */
    @PostMapping("/log-proximity-detection")
    public Mono<APIResponse<Void>> logProximityDetection(@RequestBody ProximityDetectionDTO dto) {
        LOGGER.debug("Logging proximity detection for student [{}]: {} at {}m",
                dto.getStudentIndex(), dto.getProximityLevel(), dto.getEstimatedDistance());
        return attendanceService.logProximityDetection(dto)
                .then(Mono.just(APIResponse.<Void>success(null)));
    }

    /**
     * Get proximity analytics for a specific room
     * Useful for professors to analyze classroom beacon effectiveness
     */
    @GetMapping("/proximity-analytics/{roomId}")
    public Mono<APIResponse<ProximityVerificationService.RoomProximityAnalyticsDTO>> getRoomProximityAnalytics(
            @PathVariable String roomId,
            @RequestParam(required = false, defaultValue = "7") Integer daysBack) {

        LOGGER.info("Request for proximity analytics for room [{}] for the past {} days", roomId, daysBack);
        LocalDateTime fromDate = LocalDateTime.now().minusDays(daysBack);

        return proximityVerificationService.getRoomProximityAnalytics(roomId, fromDate)
                .map(APIResponse::success);
    }
}

