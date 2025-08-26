package mk.ukim.finki.attendanceappserver.repositories;

import mk.ukim.finki.attendanceappserver.dto.DeviceLinkRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.repositories.models.StudentDevice;
import org.springframework.data.r2dbc.repository.R2dbcRepository;
import org.springframework.stereotype.Repository;
import reactor.core.publisher.Mono;

import java.util.UUID;

@Repository
public interface StudentDeviceRepository extends R2dbcRepository<StudentDevice, UUID> {
    Mono<StudentDevice> findByStudentIndex(String studentIndex);

    Mono<APIResponse<DeviceLinkRequestDTO>> getStudentDeviceByStudentIndex(String studentIndex);
}
