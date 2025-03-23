package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.ClassSessionFilterDTO;
import mk.ukim.finki.attendanceappserver.dto.db.CustomProfessorClassSession;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.services.ProfessorClassSessionService;
import mk.ukim.finki.attendanceappserver.util.DateUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/professors/class-sessions")
@AllArgsConstructor
public class ProfessorClassSessionController {

    private static final Logger LOGGER = LoggerFactory.getLogger(ProfessorClassSessionController.class);

    private ProfessorClassSessionService professorClassSessionService;

    @GetMapping(value = "/by-professor-and-date")
    public Mono<APIResponse<List<CustomProfessorClassSession>>> getProfessorClassSessionsByProfessorIdForCurrentDate(@RequestBody ClassSessionFilterDTO classSessionFilterDTO) {
        LOGGER.info("Request for retrieving class sessions by professor ID [{}] for date [{}}", classSessionFilterDTO.getProfessorId(), classSessionFilterDTO.getDate());
        return professorClassSessionService.getProfessorClassSessionsByProfessorAndDate(classSessionFilterDTO)
                .collectList()
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }

    @GetMapping(value = "/by-professor/{professorId}/current-week")
    public Mono<APIResponse<List<CustomProfessorClassSession>>> getProfessorClassSessionsByProfessorIdForCurrentWeek(@PathVariable String professorId) {
        LOGGER.info("Request for retrieving class sessions by professor ID [{}] for current week [{}]", professorId, DateUtil.getCurrentWeekNumber());
        return professorClassSessionService.getProfessorClassSessionsByProfessorIdForCurrentWeek(professorId)
                .collectList()
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }

    @GetMapping(value = "/by-professor/{professorId}/current-month")
    public Mono<APIResponse<List<CustomProfessorClassSession>>> getProfessorClassSessionsByProfessorIdForCurrentMonth(@PathVariable String professorId) {
        LOGGER.info("Request for retrieving class sessions by professor ID [{}] for current month [{}]", professorId, DateUtil.getCurrentMonthNumber());
        return professorClassSessionService.getProfessorClassSessionsByProfessorIdForCurrentMonth(professorId)
                .collectList()
                .map(APIResponse::success)
                .onErrorResume(e -> Mono.just(APIResponse.error(e.getMessage(), 500)));
    }
}
