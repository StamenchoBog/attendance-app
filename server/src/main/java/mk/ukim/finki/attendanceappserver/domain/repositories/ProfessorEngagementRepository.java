package mk.ukim.finki.attendanceappserver.domain.repositories;

import mk.ukim.finki.attendanceappserver.domain.models.ProfessorEngagement;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProfessorEngagementRepository extends R2dbcRepository<ProfessorEngagement, String> {
}
