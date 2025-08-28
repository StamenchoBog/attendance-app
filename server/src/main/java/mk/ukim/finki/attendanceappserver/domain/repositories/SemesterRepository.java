package mk.ukim.finki.attendanceappserver.domain.repositories;

import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.domain.models.Semester;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

@Repository
public interface SemesterRepository extends R2dbcRepository<Semester, String> {
    Mono<Semester> findByCode(@NonNull String code);
}
