package mk.ukim.finki.attendanceappserver.repositories;

import mk.ukim.finki.attendanceappserver.repositories.models.StudentGroup;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

@Repository
public interface StudentGroupRepository extends ReactiveCrudRepository<StudentGroup, Long> {
    Mono<StudentGroup> findByName(@NonNull String name);
}
