package mk.ukim.finki.attendanceappserver.controllers;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.ProfessorClassSessionFilterDTO;
import mk.ukim.finki.attendanceappserver.dto.StudentClassSessionFilterDTO;
import mk.ukim.finki.attendanceappserver.dto.db.ClassSessionOverview;
import mk.ukim.finki.attendanceappserver.dto.db.ProfessorClassSession;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.services.ClassSessionService;
import mk.ukim.finki.attendanceappserver.util.DateUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;

@RestController
@RequestMapping("/class-sessions")
@AllArgsConstructor
public class ClassSessionController {

    private static final Logger LOGGER = LoggerFactory.getLogger(ClassSessionController.class);

    private ClassSessionService classSessionService;

    @PostMapping(value = "/by-professor/by-date")
    public Mono<APIResponse<List<ProfessorClassSession>>> getProfessorClassSessionsByProfessorIdForCurrentDate(@RequestBody ProfessorClassSessionFilterDTO professorClassSessionFilterDTO) {
        LOGGER.info("Request for retrieving class sessions by professor ID [{}] for date [{}}", professorClassSessionFilterDTO.getProfessorId(), professorClassSessionFilterDTO.getDate());
        return classSessionService.getProfessorClassSessionsByProfessorAndDate(professorClassSessionFilterDTO)
                .collectList()
                .map(APIResponse::success);
    }

    @GetMapping(value = "/by-professor/{professorId}/current-week")
    public Mono<APIResponse<List<ProfessorClassSession>>> getProfessorClassSessionsByProfessorIdForCurrentWeek(@PathVariable String professorId) {
        LOGGER.info("Request for retrieving class sessions by professor ID [{}] for current week [{}]", professorId, DateUtil.getCurrentWeekNumber());
        return classSessionService.getProfessorClassSessionsByProfessorIdForCurrentWeek(professorId)
                .collectList()
                .map(APIResponse::success);
    }

    @GetMapping(value = "/by-professor/{professorId}/current-month")
    public Mono<APIResponse<List<ProfessorClassSession>>> getProfessorClassSessionsByProfessorIdForCurrentMonth(@PathVariable String professorId) {
        LOGGER.info("Request for retrieving class sessions by professor ID [{}] for current month [{}]", professorId, DateUtil.getCurrentMonthNumber());
        return classSessionService.getProfessorClassSessionsByProfessorIdForCurrentMonth(professorId)
                .collectList()
                .map(APIResponse::success);
    }

    //
    // Students endpoints
    //

    @PostMapping(value = "/by-student/by-date/overview")
    public Mono<APIResponse<List<ClassSessionOverview>>> getClassSessionsByStudentIndexForGivenDateAndTime(@RequestBody StudentClassSessionFilterDTO filterDTO) {
        LOGGER.info("Request for retrieving class sessions for student with index [{}] and given date and time [{}]", filterDTO.getStudentIndex(), filterDTO.getDateTime());
        return classSessionService.getClassSessionsByStudentIndexForGivenDateAndTime(filterDTO.getStudentIndex(), filterDTO.getDateTime())
                .collectList()
                .map(APIResponse::success);
    }
}
