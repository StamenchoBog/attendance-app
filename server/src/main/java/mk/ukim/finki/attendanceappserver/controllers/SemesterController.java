package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.repositories.models.Semester;
import mk.ukim.finki.attendanceappserver.services.SemesterService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/semesters")
@AllArgsConstructor
public class SemesterController {

    private static final Logger LOGGER = LoggerFactory.getLogger(SemesterController.class);

    private final SemesterService semesterService;

    @GetMapping
    public Mono<APIResponse<List<Semester>>> getSemesters() { // renamed method for clarity
        LOGGER.info("Request for retrieving all semesters");
        return semesterService.getAllSemesters()
                .collectList()
                .map(APIResponse::success);
    }

    @GetMapping(value = "/{code}")
    public Mono<APIResponse<Semester>> getSemesterByCode(@PathVariable("code") String code) {
        LOGGER.info("Request for retrieving semester with id [{}]", code);
        return semesterService.getSemesterByCode(code)
                .map(APIResponse::success);
    }

}
