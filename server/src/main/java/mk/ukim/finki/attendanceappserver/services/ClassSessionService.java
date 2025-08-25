package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.dto.ProfessorClassSessionFilterDTO;
import mk.ukim.finki.attendanceappserver.dto.db.ClassSessionOverview;
import mk.ukim.finki.attendanceappserver.dto.db.ProfessorClassSession;
import mk.ukim.finki.attendanceappserver.repositories.ClassSessionRepository;
import mk.ukim.finki.attendanceappserver.util.DateUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.util.annotation.NonNull;

import java.time.LocalDate;
import java.time.LocalDateTime;

import static mk.ukim.finki.attendanceappserver.util.DateUtil.DATE_TIME_FORMATTER;

@AllArgsConstructor
@Service
public class ClassSessionService {

    private static final Logger LOGGER = LoggerFactory.getLogger(ClassSessionService.class);

    private final ClassSessionRepository classSessionRepository;

    public Flux<ProfessorClassSession> getProfessorClassSessionsByProfessorAndDate(@NonNull ProfessorClassSessionFilterDTO professorClassSessionFilterDTO) {
        LOGGER.info("Retrieving all professor class sessions for filter [{}]", professorClassSessionFilterDTO);
        if (professorClassSessionFilterDTO.getDate() == null) {
            return Flux.error(new IllegalArgumentException("Date cannot be null"));
        }
        LocalDate date = LocalDate.parse(professorClassSessionFilterDTO.getDate());
        return classSessionRepository.getClassSessionByProfessorForDate(professorClassSessionFilterDTO.getProfessorId(),
                date);
    }

    public Flux<ProfessorClassSession> getProfessorClassSessionsByProfessorIdForCurrentWeek(@NonNull String professorId) {
        var weekStartAndEndDates = DateUtil.getWeekStartAndEndDates(LocalDate.now());
        LOGGER.info("Retrieving class sessions by professor ID [{}] for current week [{}] with dates from [{}] to [{}]",
                professorId, DateUtil.getCurrentWeekNumber(), weekStartAndEndDates[0], weekStartAndEndDates[1]);
        return classSessionRepository.getProfessorClassSessionsByProfessorIdFromDateToDate(professorId,
                weekStartAndEndDates[0], weekStartAndEndDates[1]);
    }

    public Flux<ProfessorClassSession> getProfessorClassSessionsByProfessorIdForCurrentMonth(@NonNull String professorId) {
        var monthStartAndEndDates = DateUtil.getMonthStartAndEndDates(LocalDate.now());
        LOGGER.info("Retrieving class sessions by professor ID [{}] for current month [{}] with dates from [{}] to [{}]",
                professorId, DateUtil.getCurrentWeekNumber(), monthStartAndEndDates[0], monthStartAndEndDates[1]);
        return classSessionRepository.getProfessorClassSessionsByProfessorIdFromDateToDate(professorId,
                monthStartAndEndDates[0], monthStartAndEndDates[1]);
    }

    public Flux<ClassSessionOverview> getClassSessionsByStudentIndexForGivenDateAndTime(@NonNull String studentIndex, @NonNull String dateTime) {
        LOGGER.info("Retrieving class sessions for student with index [{}] and given date and time [{}]", studentIndex, dateTime);
        var parsedDateTime = LocalDateTime.parse(dateTime, DATE_TIME_FORMATTER);
        return classSessionRepository.getClassSessionByStudentForDateAndTime(studentIndex, parsedDateTime.toLocalDate(), parsedDateTime.toLocalTime());
    }

}