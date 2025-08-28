package mk.ukim.finki.attendanceappserver.domain.repositories;

import io.micrometer.common.lang.NonNull;
import mk.ukim.finki.attendanceappserver.domain.enums.DeviceLinkStatus;
import mk.ukim.finki.attendanceappserver.domain.models.DeviceLinkRequest;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Flux;

import java.time.LocalDateTime;
import java.util.UUID;

@Repository
public interface DeviceLinkRequestRepository extends R2dbcRepository<DeviceLinkRequest, UUID> {

    Flux<DeviceLinkRequest> findByStudentIndexAndStatus(@NonNull String studentIndex, @NonNull DeviceLinkStatus status);

    Flux<DeviceLinkRequest> findByStatus(DeviceLinkStatus status);

    @Query("SELECT * FROM device_link_request WHERE student_index = :studentIndex AND request_timestamp >= :timestamp")
    Flux<DeviceLinkRequest> findRecentRequestsForStudent(String studentIndex, LocalDateTime timestamp);
}
