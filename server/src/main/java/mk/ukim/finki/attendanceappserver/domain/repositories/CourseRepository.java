package mk.ukim.finki.attendanceappserver.domain.repositories;

import mk.ukim.finki.attendanceappserver.domain.models.Course;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.util.annotation.NonNull;

@Repository
public interface CourseRepository extends R2dbcRepository<Course, Long> {
    Flux<Course> findByProfessorId(@NonNull String professorId);
}
