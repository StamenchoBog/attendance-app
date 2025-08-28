package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.domain.repositories.RoomRepository;
import mk.ukim.finki.attendanceappserver.domain.models.Room;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

@AllArgsConstructor
@Service
public class RoomService {

    private static final Logger LOGGER = LoggerFactory.getLogger(RoomService.class);

    private final RoomRepository roomRepository;

    public Flux<Room> getRooms() {
        LOGGER.info("Retrieving all rooms from database");
        return roomRepository.findAll();
    }

    public Mono<Room> getRoomByName(@NonNull String name) {
        LOGGER.info("Retrieving room with name [{}] from database", name);
        return roomRepository.findById(name);
    }

    public Mono<Room> getRoomByLocationDescriptionLike(@NonNull String description) {
        LOGGER.info("Retrieving room with location description [{}] from database", description);
        return roomRepository.findByLocationDescriptionIsLike(description);
    }
}
