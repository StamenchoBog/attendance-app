package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.domain.repositories.ProfessorRepository;
import mk.ukim.finki.attendanceappserver.domain.models.Professor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

@AllArgsConstructor
@Service
public class ProfessorService {

    private static final Logger LOGGER = LoggerFactory.getLogger(ProfessorService.class);

    private final ProfessorRepository professorRepository;

    public Flux<Professor> getProfessors() {
        LOGGER.info("Retrieving all professors from database");
        return professorRepository.findAll();
    }

    public Mono<Professor> getProfessorById(@NonNull String id) {
        LOGGER.info("Retrieving professor with id [{}] from database", id);
        return professorRepository.findById(id);
    }
}
