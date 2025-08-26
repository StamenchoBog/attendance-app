package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.domain.enums.DeviceLinkStatus;
import mk.ukim.finki.attendanceappserver.dto.DeviceLinkRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.repositories.DeviceLinkRequestRepository;
import mk.ukim.finki.attendanceappserver.repositories.StudentDeviceRepository;
import mk.ukim.finki.attendanceappserver.repositories.models.DeviceLinkRequest;
import mk.ukim.finki.attendanceappserver.repositories.models.StudentDevice;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

@Service
@AllArgsConstructor
public class DeviceManagementService {

    private final DeviceLinkRequestRepository deviceLinkRequestRepository;
    private final StudentDeviceRepository studentDeviceRepository;

    public Mono<APIResponse<DeviceLinkRequestDTO>> getRegisteredDevices(String studentIndex) {
        return studentDeviceRepository.getStudentDeviceByStudentIndex(studentIndex);
    }

    public Mono<Void> createDeviceLinkRequest(String studentIndex, DeviceLinkRequestDTO request) {
        return deviceLinkRequestRepository.findByStudentIndexAndStatus(studentIndex, DeviceLinkStatus.PENDING)
                .flatMap(existingRequest -> {
                    existingRequest.setId(existingRequest.getId());
                    existingRequest.setDeviceId(request.getDeviceId());
                    existingRequest.setDeviceName(request.getDeviceName());
                    existingRequest.setDeviceOs(request.getDeviceOs());
                    existingRequest.setStatus(DeviceLinkStatus.PENDING);
                    return deviceLinkRequestRepository.save(existingRequest);
                })
                .switchIfEmpty(Mono.defer(() -> {
                    var newDeviceLinkRequest = DeviceLinkRequest.builder()
                            .studentIndex(studentIndex)
                            .deviceId(request.getDeviceId())
                            .deviceName(request.getDeviceName())
                            .deviceOs(request.getDeviceOs())
                            .status(DeviceLinkStatus.PENDING)
                            .build();
                    return deviceLinkRequestRepository.save(newDeviceLinkRequest);
                })).then();
    }

    public Mono<Void> approveDeviceLink(DeviceLinkRequest request) {
        return studentDeviceRepository.findByStudentIndex(request.getStudentIndex())
                .flatMap(studentDevice -> {
                    studentDevice.setDeviceId(request.getDeviceId());
                    return studentDeviceRepository.save(studentDevice);
                })
                .switchIfEmpty(Mono.defer(() -> {
                    StudentDevice newStudentDevice = StudentDevice.builder()
                            .studentIndex(request.getStudentIndex())
                            .deviceId(request.getDeviceId())
                            .deviceId(request.getDeviceId())
                            .deviceName(request.getDeviceName())
                            .deviceOs(request.getDeviceOs())
                            .build();
                    return studentDeviceRepository.save(newStudentDevice);
                }))
                .flatMap(savedDevice -> {
                    request.setStatus(DeviceLinkStatus.AUTO_APPROVED);
                    return deviceLinkRequestRepository.save(request);
                })
                .then();
    }

    public Mono<Void> flagDeviceLinkRequest(DeviceLinkRequest request) {
        request.setStatus(DeviceLinkStatus.FLAGGED_FOR_REVIEW);
        request.setNotes("Flagged due to recent device change request.");
        return deviceLinkRequestRepository.save(request).then();
    }
}
