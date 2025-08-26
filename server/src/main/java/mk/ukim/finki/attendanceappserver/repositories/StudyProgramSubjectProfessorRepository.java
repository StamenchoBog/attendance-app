package mk.ukim.finki.attendanceappserver.repositories;

import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.repositories.models.StudyProgramSubjectProfessor;
import mk.ukim.finki.attendanceappserver.repositories.models.Subject;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;

@Repository
public interface StudyProgramSubjectProfessorRepository extends R2dbcRepository<StudyProgramSubjectProfessor, String> {

    @Query("SELECT DISTINCT s.* " +
            "FROM subject s " +
            "INNER JOIN study_program_subject sps ON s.id = sps.subject_id " +
            "INNER JOIN study_program_subject_professor spsp ON sps.id = spsp.study_program_subject_id " +
            "WHERE spsp.professor_id = :professorId")
    Flux<Subject> getAllSubjectsByProfessorId(@NonNull String professorId);
}
