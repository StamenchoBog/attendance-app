package mk.ukim.finki.attendanceappserver.repositories;

import mk.ukim.finki.attendanceappserver.repositories.models.ProfessorEngagement;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ProfessorEngagementRepository extends ReactiveCrudRepository<ProfessorEngagement, String> {
}
