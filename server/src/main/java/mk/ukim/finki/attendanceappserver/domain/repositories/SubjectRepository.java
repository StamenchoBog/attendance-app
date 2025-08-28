package mk.ukim.finki.attendanceappserver.domain.repositories;

import mk.ukim.finki.attendanceappserver.domain.models.Subject;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SubjectRepository extends R2dbcRepository<Subject, String> {
}
