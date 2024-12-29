package mk.ukim.finki.attendanceappserver.repositories;

import mk.ukim.finki.attendanceappserver.repositories.models.Course;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CourseRepository extends ReactiveCrudRepository<Course, Long> {
}
