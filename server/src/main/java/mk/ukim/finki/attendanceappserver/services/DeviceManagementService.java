package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import mk.ukim.finki.attendanceappserver.domain.enums.DeviceLinkStatus;
import mk.ukim.finki.attendanceappserver.dto.DeviceLinkRequestDTO;
import mk.ukim.finki.attendanceappserver.dto.generic.APIResponse;
import mk.ukim.finki.attendanceappserver.domain.repositories.DeviceLinkRequestRepository;
import mk.ukim.finki.attendanceappserver.domain.repositories.StudentDeviceRepository;
import mk.ukim.finki.attendanceappserver.domain.models.DeviceLinkRequest;
import mk.ukim.finki.attendanceappserver.domain.models.StudentDevice;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

@Service
@AllArgsConstructor
public class DeviceManagementService {

    private final DeviceLinkRequestRepository deviceLinkRequestRepository;
    private final StudentDeviceRepository studentDeviceRepository;

    public Mono<APIResponse<DeviceLinkRequestDTO>> getRegisteredDevices(String studentIndex) {
        return studentDeviceRepository.findByStudentIndex(studentIndex)
                .map(studentDevice -> {
                    DeviceLinkRequestDTO dto = DeviceLinkRequestDTO.builder()
                            .deviceId(studentDevice.getDeviceId())
                            .deviceName(studentDevice.getDeviceName())
                            .deviceOs(studentDevice.getDeviceOs())
                            .build();
                    return APIResponse.success(dto);
                })
                .defaultIfEmpty(APIResponse.success(null));
    }

    public Mono<Boolean> isDeviceApprovedForStudent(String studentIndex, String deviceId) {
        return studentDeviceRepository.findByStudentIndex(studentIndex)
                .map(studentDevice -> studentDevice.getDeviceId().equals(deviceId))
                .defaultIfEmpty(false);
    }

    public Mono<Boolean> hasRegisteredDevice(String studentIndex) {
        return studentDeviceRepository.findByStudentIndex(studentIndex)
                .hasElement();
    }

    public Mono<Void> registerFirstTimeDevice(String studentIndex, DeviceLinkRequestDTO request) {
        // Validate input parameters
        if (studentIndex == null || studentIndex.trim().isEmpty()) {
            return Mono.error(new IllegalArgumentException("Student index cannot be empty"));
        }
        if (request.getDeviceId() == null || request.getDeviceId().trim().isEmpty()) {
            return Mono.error(new IllegalArgumentException("Device ID cannot be empty"));
        }
        
        return hasRegisteredDevice(studentIndex)
                .flatMap(hasDevice -> {
                    if (hasDevice) {
                        return Mono.error(new IllegalStateException("DEVICE_ALREADY_REGISTERED"));
                    }
                    
                    // For first-time registration, auto-approve immediately
                    StudentDevice newStudentDevice = StudentDevice.builder()
                            .studentIndex(studentIndex)
                            .deviceId(request.getDeviceId())
                            .deviceName(request.getDeviceName())
                            .deviceOs(request.getDeviceOs())
                            .build();
                    
                    return studentDeviceRepository.save(newStudentDevice).then();
                })
                .onErrorMap(IllegalStateException.class, ex -> 
                    new IllegalStateException("DEVICE_ALREADY_REGISTERED"))
                .onErrorMap(Exception.class, ex -> 
                    new RuntimeException("DEVICE_REGISTRATION_FAILED"));
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
