package mk.ukim.finki.attendanceappserver.domain.repositories;

import mk.ukim.finki.attendanceappserver.domain.models.Professor;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProfessorRepository extends R2dbcRepository<Professor, String> {
}
