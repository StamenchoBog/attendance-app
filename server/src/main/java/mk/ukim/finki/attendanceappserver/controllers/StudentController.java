package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.AttendanceSummaryDTO;
import mk.ukim.finki.attendanceappserver.dto.DeviceLinkRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.repositories.models.Student;
import mk.ukim.finki.attendanceappserver.services.AttendanceService;
import mk.ukim.finki.attendanceappserver.services.DeviceManagementService;
import mk.ukim.finki.attendanceappserver.services.StudentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/students")
@AllArgsConstructor
public class StudentController {

    private final StudentService studentService;
    private final AttendanceService attendanceService;
    private final DeviceManagementService deviceManagementService;

    private static final Logger LOGGER = LoggerFactory.getLogger(StudentController.class);

    @GetMapping
    public Mono<APIResponse<List<Student>>> getStudents() {
        LOGGER.info("Request for retrieving all students");
        return studentService.getStudents()
                .collectList()
                .map(APIResponse::success);
    }

    @GetMapping(value = "/{studentIndex}")
    public Mono<APIResponse<Student>> getStudentByIndex(@PathVariable String studentIndex) {
        LOGGER.info("Request for retrieving student by student index [{}]", studentIndex);
        return studentService.getStudentByIndex(studentIndex)
                .map(APIResponse::success);
    }

    @GetMapping(value = "/by-professor/{professorId}")
    public Mono<APIResponse<List<Student>>> getStudentsByCourseAndProfessor(@PathVariable String professorId) {
        LOGGER.info("Request for retrieving all students grouped by course and by professor with ID [{}]", professorId);
        return studentService.findStudentsEnrolledOnSubjectsWithProfessorId(professorId)
                .collectList()
                .map(APIResponse::success);
    }

    @GetMapping("/is-valid/{studentIndex}")
    public Mono<APIResponse<Boolean>> isStudentValid(@PathVariable String studentIndex) {
        LOGGER.info("Request for validating student with student index [{}]", studentIndex);
        return studentService.isStudentValid(studentIndex)
                .map(APIResponse::success);
    }

    @GetMapping("/{studentIndex}/attendance-summary")
    public Mono<APIResponse<AttendanceSummaryDTO>> getAttendanceSummary(
            @PathVariable String studentIndex,
            @RequestParam String semester) {
        LOGGER.info("Request for attendance summary for student [{}] and semester [{}]", studentIndex, semester);
        return attendanceService.getAttendanceSummary(studentIndex, semester)
                .map(APIResponse::success);
    }

    @GetMapping("/{studentIndex}/registered-device")
    public Mono<APIResponse<DeviceLinkRequestDTO>> getRegisteredDevices(@PathVariable String studentIndex) {
        LOGGER.info("Request for registered devices for student [{}]", studentIndex);
        return deviceManagementService.getRegisteredDevices(studentIndex);
    }

    @PostMapping("/{studentIndex}/device-link-request")
    public Mono<APIResponse<Void>> requestDeviceLink(@PathVariable String studentIndex, @RequestBody DeviceLinkRequestDTO dto) {
        LOGGER.info("Request to link a new device for student [{}]", studentIndex);
        return deviceManagementService.createDeviceLinkRequest(studentIndex, dto)
                .then(Mono.just(APIResponse.<Void>success(null)));
    }
}
