package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.domain.repositories.CourseRepository;
import mk.ukim.finki.attendanceappserver.domain.models.Course;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

@AllArgsConstructor
@Service
public class CourseService {

    private static final Logger LOGGER = LoggerFactory.getLogger(CourseService.class);

    private final CourseRepository courseRepository;

    /**
     * Retrieve all course
     * @return courses
     */
    public Flux<Course> getCourses() {
        LOGGER.info("Retrieving all courses from database");
        return courseRepository.findAll();
    }

    /**
     * Retrieve course by ID
     * @param id unique identifier for the course
     * @return information about the course
     */
    public Mono<Course> getCourse(@NonNull Long id) {
        LOGGER.info("Retrieving course with id {} from database", id);
        return courseRepository.findById(id);
    }
}
