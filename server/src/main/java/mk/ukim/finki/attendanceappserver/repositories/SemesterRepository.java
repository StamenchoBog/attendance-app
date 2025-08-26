package mk.ukim.finki.attendanceappserver.repositories;

import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.repositories.models.Semester;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public interface SemesterRepository extends R2dbcRepository<Semester, String> {
    Mono<Semester> findByCode(@NonNull String code);
}
