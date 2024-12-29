package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.repositories.models.Course;
import mk.ukim.finki.attendanceappserver.services.CourseService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

@RestController
@RequestMapping("/courses")
@AllArgsConstructor
public class CourseController {

    private static final Logger LOGGER = LoggerFactory.getLogger(CourseController.class);

    private CourseService courseService;

    @GetMapping
    Flux<Course> getClasses() {
        LOGGER.info("Retrieving all courses");
        return courseService.getCourses();
    }
}
