package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.repositories.StudyProgramSubjectProfessorRepository;
import mk.ukim.finki.attendanceappserver.repositories.SubjectRepository;
import mk.ukim.finki.attendanceappserver.repositories.models.Subject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

@AllArgsConstructor
@Service
public class SubjectService {

    private static final Logger LOGGER = LoggerFactory.getLogger(SubjectService.class);

    private final SubjectRepository subjectRepository;
    private final StudyProgramSubjectProfessorRepository studyProgramSubjectProfessorRepository;

    public Flux<Subject> getSubjects() {
        LOGGER.info("Retrieving all subjects from database");
        return subjectRepository.findAll();
    }

    public Mono<Subject> getSubjectById(@NonNull String id) {
        LOGGER.info("Retrieving subjects with id {} from database", id);
        return subjectRepository.findById(id);
    }

    public Flux<Subject> getSubjectsByProfessorId(@NonNull String professorId) {
        LOGGER.info("Retrieving subjects which are associated with professor id {} from database", professorId);
        return studyProgramSubjectProfessorRepository.getAllSubjectsByProfessorId(professorId);
    }
}
