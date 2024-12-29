package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.repositories.CourseRepository;
import mk.ukim.finki.attendanceappserver.repositories.models.Course;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

@AllArgsConstructor
@Service
public class CourseService {

    private final CourseRepository courseRepository;

    public Flux<Course> getCourses() {
        return courseRepository.findAll();
    }
}
