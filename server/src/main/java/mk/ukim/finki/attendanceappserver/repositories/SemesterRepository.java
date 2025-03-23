package mk.ukim.finki.attendanceappserver.repositories;

import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.repositories.models.Semester;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public interface SemesterRepository extends ReactiveCrudRepository<Semester, String> {
    Mono<Semester> findByCode(@NonNull String code);
}
