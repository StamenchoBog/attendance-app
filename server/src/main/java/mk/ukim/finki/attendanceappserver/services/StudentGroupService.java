package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.repositories.StudentGroupRepository;
import mk.ukim.finki.attendanceappserver.repositories.models.StudentGroup;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

@AllArgsConstructor
@Service
public class StudentGroupService {

    private static final Logger LOGGER = LoggerFactory.getLogger(StudentGroupService.class);

    private final StudentGroupRepository studentGroupRepository;

    public Flux<StudentGroup> getAllStudentGroups() {
        LOGGER.info("Retrieving all students groups from database");
        return studentGroupRepository.findAll();
    }

    public Mono<StudentGroup> getStudentGroupById(@NonNull Long id) {
        LOGGER.info("Retrieving student group by ID [{}] from database", id);
        return studentGroupRepository.findById(id);
    }

    public Mono<StudentGroup> getStudentGroupByName(@NonNull String name) {
        LOGGER.info("Retrieving student group by name [{}] from database", name);
        return studentGroupRepository.findByName(name);
    }
}
