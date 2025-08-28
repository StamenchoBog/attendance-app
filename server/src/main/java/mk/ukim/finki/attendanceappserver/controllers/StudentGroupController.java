package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.domain.models.StudentGroup;
import mk.ukim.finki.attendanceappserver.services.StudentGroupService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/students/groups")
@AllArgsConstructor
public class StudentGroupController {

    private static final Logger LOGGER = LoggerFactory.getLogger(StudentGroupController.class);

    private final StudentGroupService studentGroupService;

    @GetMapping
    public Mono<APIResponse<List<StudentGroup>>> getStudentGroups() {
        LOGGER.info("Request for retrieving all student groups");
        return studentGroupService.getAllStudentGroups()
                .collectList()
                .map(APIResponse::success);
    }

    @GetMapping(value = "/{id}")
    public Mono<APIResponse<StudentGroup>> getStudentGroupById(@PathVariable Long id) {
        LOGGER.info("Request for retrieving student group with ID [{}]", id);
        return studentGroupService.getStudentGroupById(id)
                .map(APIResponse::success);
    }

    @GetMapping(value = "/name/{name}")
    public Mono<APIResponse<StudentGroup>> getStudentGroupByName(@PathVariable String name) {
        LOGGER.info("Request for retrieving student group with name [{}]", name);
        return studentGroupService.getStudentGroupByName(name)
                .map(APIResponse::success);
    }
}
