package mk.ukim.finki.attendanceappserver.repositories;

import mk.ukim.finki.attendanceappserver.repositories.models.Subject;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SubjectRepository extends ReactiveCrudRepository<Subject, String> {
}
