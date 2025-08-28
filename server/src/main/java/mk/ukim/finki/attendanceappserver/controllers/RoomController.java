package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.domain.models.Room;
import mk.ukim.finki.attendanceappserver.services.RoomService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
                .map(APIResponse::success);
    }

    @GetMapping(value = "/{name}")
    public Mono<APIResponse<Room>> getRoomByName(@PathVariable String name) {
        LOGGER.info("Request for retrieving room by name [{}]", name);
        return roomService.getRoomByName(name)
                .map(APIResponse::success);
    }

    @GetMapping(value = "/by-location/{locationDescription}")
    public Mono<APIResponse<Room>> getRoomByLocationDescription(@PathVariable String locationDescription) {
        LOGGER.info("Request for retrieving room by location description [{}]", locationDescription);
        return roomService.getRoomByLocationDescriptionLike(locationDescription)
                .map(APIResponse::success);
    }
}
