package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.repositories.models.Professor;
import mk.ukim.finki.attendanceappserver.services.ProfessorService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/professors")
@AllArgsConstructor
public class ProfessorController {

    private final ProfessorService professorService;

    private static final Logger LOGGER = LoggerFactory.getLogger(ProfessorController.class);

    @GetMapping
    public Mono<APIResponse<List<Professor>>> getProfessors() {
        LOGGER.info("Request for retrieving all professors");
        return professorService.getProfessors()
                .collectList()
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }

    @GetMapping(value = "/{id}")
    public Mono<ResponseEntity<APIResponse<Professor>>> getProfessor(@NonNull @PathVariable("id") String id) {
        LOGGER.info("Request for retrieving professor [{}]", id);
        return professorService.getProfessorById(id)
                .map(professor -> ResponseEntity.ok(APIResponse.success(professor)))
                .switchIfEmpty(Mono.just(ResponseEntity.notFound().build()))
                .onErrorResume(e -> Mono.just(ResponseEntity.internalServerError().body(APIResponse.error(e.getMessage(), 500))));
    }
}
