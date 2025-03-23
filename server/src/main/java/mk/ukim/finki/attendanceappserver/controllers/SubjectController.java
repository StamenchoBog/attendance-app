package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.repositories.models.Subject;
import mk.ukim.finki.attendanceappserver.services.SubjectService;
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
@RequestMapping("/subjects")
@AllArgsConstructor
public class SubjectController {

    private static final Logger LOGGER = LoggerFactory.getLogger(SubjectController.class);

    private SubjectService subjectService;

    @GetMapping
    public Mono<APIResponse<List<Subject>>> getSubjects() {
        LOGGER.info("Request for retrieving all subjects");
        return subjectService.getSubjects()
                .collectList()
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }

    @GetMapping(value = "/{id}")
    public Mono<ResponseEntity<APIResponse<Subject>>> getSubject(@PathVariable String id) {
        LOGGER.info("Request for retrieving subject with id [{}]", id);
        return subjectService.getSubjectById(id)
                .map(subject -> ResponseEntity.ok(APIResponse.success(subject)))
                .switchIfEmpty(Mono.just(ResponseEntity.notFound().build()))
                .onErrorResume(e -> Mono.just(ResponseEntity.internalServerError().body(APIResponse.error(e.getMessage(), 500))));
    }

    @GetMapping(value = "/by-professor/{professorId}")
    public Mono<APIResponse<List<Subject>>> getSubjectsByProfessorId(@PathVariable String professorId) {
        LOGGER.info("Request for retrieving all subjects associated with professor id [{}]", professorId);
        return subjectService.getSubjectsByProfessorId(professorId)
                .collectList()
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }

    // TODO: Get lectures about a subject.
    // Input: Subject ID.
    // Output: List of lectures about a subject.

    // TODO: GET /courses/{subjectId}/students: Retrieves students enrolled in a course.
    //       Input: Subject ID.
    //       Output: List of student details.
}
