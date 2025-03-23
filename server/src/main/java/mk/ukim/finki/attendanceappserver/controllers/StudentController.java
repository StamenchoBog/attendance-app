package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.repositories.models.Student;
import mk.ukim.finki.attendanceappserver.services.StudentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/students")
@AllArgsConstructor
public class StudentController {

    private final StudentService studentService;

    private static final Logger LOGGER = LoggerFactory.getLogger(StudentController.class);

    @GetMapping
    public Mono<APIResponse<List<Student>>> getStudents() {
        LOGGER.info("Request for retrieving all students");
        return studentService.getStudents()
                .collectList()
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }

    @GetMapping(value = "/{studentIndex}")
    public Mono<ResponseEntity<APIResponse<Student>>> getStudentByIndex(@PathVariable String studentIndex) {
        LOGGER.info("Request for retrieving student by student index [{}]", studentIndex);
        return studentService.getStudentByIndex(studentIndex)
                .map(student -> ResponseEntity.ok(APIResponse.success(student)))
                .switchIfEmpty(Mono.just(ResponseEntity.notFound().build()))
                .onErrorResume(e -> Mono.just(ResponseEntity.internalServerError().body(APIResponse.error(e.getMessage(), 500))));
    }

    @GetMapping(value = "/by-professor/{professorId}")
    public Mono<APIResponse<List<Student>>> getStudentsByCourseAndProfessor(@PathVariable String professorId) {
        LOGGER.info("Request for retrieving all students grouped by course and by professor with ID [{}]", professorId);
        return studentService.findStudentsEnrolledOnSubjectsWithProfessorId(professorId)
                .collectList()
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }

    @GetMapping("/is-valid/{studentIndex}")
    public Mono<ResponseEntity<APIResponse<Boolean>>> isStudentValid(@PathVariable String studentIndex) {
        LOGGER.info("Request for validating student with student index [{}]", studentIndex);
        return studentService.isStudentValid(studentIndex)
                .map(isValid -> ResponseEntity.ok(APIResponse.success(isValid)))
                .onErrorResume(e -> Mono.just(ResponseEntity.internalServerError().body(APIResponse.error(e.getMessage(), 500))));
    }
}
