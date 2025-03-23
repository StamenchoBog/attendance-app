package mk.ukim.finki.attendanceappserver.repositories;

import mk.ukim.finki.attendanceappserver.repositories.models.Room;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

@Repository
public interface RoomRepository extends ReactiveCrudRepository<Room, String> {
    Mono<Room> findByLocationDescriptionIsLike(@NonNull String locationDescription);
}
