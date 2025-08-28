package mk.ukim.finki.attendanceappserver.domain.repositories;

import mk.ukim.finki.attendanceappserver.domain.models.ProximityVerificationLog;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;

@Repository
public interface ProximityVerificationRepository extends ReactiveCrudRepository<ProximityVerificationLog, Long> {

    @Query("SELECT * FROM proximity_verification_log WHERE student_attendance_id = :attendanceId ORDER BY verification_timestamp DESC")
    Flux<ProximityVerificationLog> findByStudentAttendanceId(Integer attendanceId);

    @Query("SELECT * FROM proximity_verification_log WHERE student_index = :studentIndex AND verification_timestamp >= :fromDate ORDER BY verification_timestamp DESC")
    Flux<ProximityVerificationLog> findByStudentIndexAndDateRange(String studentIndex, LocalDateTime fromDate);

    @Query("SELECT * FROM proximity_verification_log WHERE session_token = :sessionToken ORDER BY verification_timestamp DESC")
    Flux<ProximityVerificationLog> findBySessionToken(String sessionToken);

    @Query("SELECT * FROM proximity_verification_log WHERE detected_room_id = :roomId AND verification_timestamp >= :fromDate")
    Flux<ProximityVerificationLog> findByRoomIdAndDateRange(String roomId, LocalDateTime fromDate);

    @Query("SELECT COUNT(*) FROM proximity_verification_log WHERE verification_status = 'SUCCESS' AND verification_timestamp >= :fromDate")
    Mono<Long> countSuccessfulVerificationsFromDate(LocalDateTime fromDate);

    @Query("SELECT AVG(estimated_distance) FROM proximity_verification_log WHERE verification_status = 'SUCCESS' AND detected_room_id = :roomId AND verification_timestamp >= :fromDate")
    Mono<Double> getAverageDistanceByRoomAndDateRange(String roomId, LocalDateTime fromDate);
}
