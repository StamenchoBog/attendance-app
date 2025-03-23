package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.repositories.ProfessorRepository;
import mk.ukim.finki.attendanceappserver.repositories.StudentRepository;
import mk.ukim.finki.attendanceappserver.repositories.models.Student;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;
import reactor.util.annotation.NonNull;

import java.math.BigInteger;

import static mk.ukim.finki.attendanceappserver.util.ValidationUtil.validateEntityExists;

@AllArgsConstructor
@Service
public class StudentService {

    private static final Logger LOGGER = LoggerFactory.getLogger(StudentService.class);

    private final StudentRepository studentRepository;
    private final ProfessorRepository professorRepository;

    public Flux<Student> getStudents() {
        LOGGER.info("Retrieving all students from database");
        return studentRepository.findAll();
    }

    public Mono<Student> getStudentByIndex(@NonNull String studentIndex) {
        LOGGER.info("Retrieving student by index [{}] from database", studentIndex);
        return studentRepository.findByStudentIndex(studentIndex);
    }

    public Mono<Boolean> isStudentValid(@NonNull String studentIndex) {
        LOGGER.info("Checking if a student with student index [{}] is enrolled on semester with valid status.", studentIndex);
        return studentRepository.checkStudentValidity(studentIndex).map(o -> o.compareTo(BigInteger.ZERO) > 0);
    }

    public Flux<Student> findStudentsEnrolledOnSubjectsWithProfessorId(@NonNull String professorId) {
        LOGGER.info("Retrieving students by courses which the professor with ID [{}] teaches.", professorId);
        return validateEntityExists(professorRepository, professorId)
                .thenMany(studentRepository.findStudentsEnrolledOnSubjectsWithProfessorId(professorId));
    }

    //TODO: Fetch students which have enrolled on course with ID.
    //public Flux<Student> getStudentsEnrolledOnSubjectWithId(String subjectId) {
    //    LOGGER.info("Retrieving students which enrolled on subject with ID [{}].", subjectId);
        //return validateEntityExists(subjectRepository, subjectId)
        //        .thenMany(studentRepository.findStudentsBySubjectId(subjectId))
        //        .switchIfEmpty(Flux.empty());

    //}
}
