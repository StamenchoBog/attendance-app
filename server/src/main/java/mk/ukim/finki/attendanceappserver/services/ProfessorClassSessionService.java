package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.ClassSessionFilterDTO;
import mk.ukim.finki.attendanceappserver.dto.db.CustomProfessorClassSession;
import mk.ukim.finki.attendanceappserver.repositories.ProfessorClassSessionRepository;
import mk.ukim.finki.attendanceappserver.util.DateUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.util.annotation.NonNull;

import java.time.LocalDate;

@AllArgsConstructor
@Service
public class ProfessorClassSessionService {

    private static final Logger LOGGER = LoggerFactory.getLogger(ProfessorClassSessionService.class);

    private final ProfessorClassSessionRepository professorClassSessionRepository;

    public Flux<CustomProfessorClassSession> getProfessorClassSessionsByProfessorAndDate(@NonNull ClassSessionFilterDTO classSessionFilterDTO) {
        LOGGER.info("Retrieving all professor class sessions for filter [{}]", classSessionFilterDTO);
        return professorClassSessionRepository.getClassSessionByProfessorForDate(classSessionFilterDTO.getProfessorId(),
                classSessionFilterDTO.getDate());
    }

    public Flux<CustomProfessorClassSession> getProfessorClassSessionsByProfessorIdForCurrentWeek(@NonNull String professorId) {
        var weekStartAndEndDates = DateUtil.getWeekStartAndEndDates(LocalDate.now());
        LOGGER.info("Retrieving class sessions by professor ID [{}] for current week [{}] with dates from [{}] to [{}]",
                professorId, DateUtil.getCurrentWeekNumber(), weekStartAndEndDates[0], weekStartAndEndDates[1]);
        return professorClassSessionRepository.getProfessorClassSessionsByProfessorIdFromDateToDate(professorId,
                weekStartAndEndDates[0], weekStartAndEndDates[1]);
    }

    public Flux<CustomProfessorClassSession> getProfessorClassSessionsByProfessorIdForCurrentMonth(@NonNull String professorId) {
        var monthStartAndEndDates = DateUtil.getMonthStartAndEndDates(LocalDate.now());
        LOGGER.info("Retrieving class sessions by professor ID [{}] for current month [{}] with dates from [{}] to [{}]",
                professorId, DateUtil.getCurrentWeekNumber(), monthStartAndEndDates[0], monthStartAndEndDates[1]);
        return professorClassSessionRepository.getProfessorClassSessionsByProfessorIdFromDateToDate(professorId,
                monthStartAndEndDates[0], monthStartAndEndDates[1]);
    }

}
