package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.repositories.SemesterRepository;
import mk.ukim.finki.attendanceappserver.repositories.models.Semester;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

@AllArgsConstructor
@Service
public class SemesterService {

    private static final Logger LOGGER = LoggerFactory.getLogger(SemesterService.class);

    private SemesterRepository semesterRepository;

    /**
     * Returns all semesters
     * @return data about semesters
     */
    public Flux<Semester> getAllSemesters() {
        LOGGER.info("Retrieving all semesters from database");
        return semesterRepository.findAll();
    }

    /**
     * Returns a semester based on its ID
     * @param code unique identifier for the semester
     * @return data about the filtered semester
     */
    public Mono<Semester> getSemesterByCode(@NonNull String code) {
        LOGGER.info("Retrieving semester with code [{}] from database", code);
        return semesterRepository.findByCode(code);
    }
}
