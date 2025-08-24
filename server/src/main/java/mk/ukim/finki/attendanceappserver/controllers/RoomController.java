package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.repositories.models.Room;
import mk.ukim.finki.attendanceappserver.services.RoomService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/rooms")
@AllArgsConstructor
public class RoomController {

    private static final Logger LOGGER = LoggerFactory.getLogger(RoomController.class);

    private RoomService roomService;

    @GetMapping
    public Mono<APIResponse<List<Room>>> getRooms() {
        LOGGER.info("Request for retrieving all rooms");
        return roomService.getRooms()
                .collectList()
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }

    @GetMapping(value = "/{name}")
    public Mono<ResponseEntity<APIResponse<Room>>> getRoomByName(@PathVariable String name) {
        LOGGER.info("Request for retrieving room by name [{}]", name);
        return roomService.getRoomByName(name)
                .map(room -> ResponseEntity.ok(APIResponse.success(room)))
                .switchIfEmpty(Mono.just(ResponseEntity.notFound().build()))
                .onErrorResume(e -> Mono.just(ResponseEntity.internalServerError().body(APIResponse.error(e.getMessage(), 500))));
    }

    @GetMapping(value = "/by-location/{locationDescription}")
    public Mono<ResponseEntity<APIResponse<Room>>> getRoomByLocationDescription(@PathVariable String locationDescription) {
        LOGGER.info("Request for retrieving room by location description [{}]", locationDescription);
        return roomService.getRoomByLocationDescriptionLike(locationDescription)
                .map(room -> ResponseEntity.ok(APIResponse.success(room)))
                .switchIfEmpty(Mono.just(ResponseEntity.notFound().build()))
                .onErrorResume(e -> Mono.just(ResponseEntity.internalServerError().body(APIResponse.error(e.getMessage(), 500))));
    }
}
