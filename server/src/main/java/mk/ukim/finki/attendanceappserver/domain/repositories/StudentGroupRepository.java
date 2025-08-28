package mk.ukim.finki.attendanceappserver.domain.repositories;

import mk.ukim.finki.attendanceappserver.domain.models.StudentGroup;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

@Repository
public interface StudentGroupRepository extends R2dbcRepository<StudentGroup, Long> {
    Mono<StudentGroup> findByName(@NonNull String name);
}
