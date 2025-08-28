package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.domain.models.Course;
import mk.ukim.finki.attendanceappserver.services.CourseService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/courses")
@AllArgsConstructor
public class CourseController {

    private static final Logger LOGGER = LoggerFactory.getLogger(CourseController.class);

    private final CourseService courseService;

    @GetMapping
    public Mono<APIResponse<List<Course>>> getCourses() {
        LOGGER.info("Request for retrieving all courses");
        return courseService.getCourses()
                .collectList()
                .map(APIResponse::success);
    }

    @GetMapping(value = "/{id}")
    public Mono<APIResponse<Course>> getCourse(@PathVariable Long id) {
        LOGGER.info("Request for retrieving course with id [{}]", id);
        return courseService.getCourse(id)
                .map(APIResponse::success);
    }
}
