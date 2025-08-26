package mk.ukim.finki.attendanceappserver.repositories;

import mk.ukim.finki.attendanceappserver.repositories.models.Room;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

@Repository
public interface RoomRepository extends R2dbcRepository<Room, String> {
    Mono<Room> findByLocationDescriptionIsLike(@NonNull String locationDescription);
}
