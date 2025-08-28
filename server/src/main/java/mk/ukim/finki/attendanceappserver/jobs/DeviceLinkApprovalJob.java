package mk.ukim.finki.attendanceappserver.jobs;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import mk.ukim.finki.attendanceappserver.config.DeviceLinkProperties;
import mk.ukim.finki.attendanceappserver.domain.enums.DeviceLinkStatus;
import mk.ukim.finki.attendanceappserver.domain.repositories.DeviceLinkRequestRepository;
import mk.ukim.finki.attendanceappserver.services.DeviceManagementService;
import mk.ukim.finki.attendanceappserver.services.EmailService;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@AllArgsConstructor
@Slf4j
public class DeviceLinkApprovalJob {

    private final DeviceLinkRequestRepository deviceLinkRequestRepository;
    private final DeviceManagementService deviceManagementService;
    private final EmailService emailService;
    private final DeviceLinkProperties deviceLinkProperties;

    @Scheduled(fixedRate = 300000) // Runs every 5 minutes
    public void processPendingDeviceLinkRequests() {
        log.info("Starting scheduled job: Process Pending Device Link Requests");

        deviceLinkRequestRepository.findByStatus(DeviceLinkStatus.PENDING)
                .flatMap(request -> {
                    LocalDateTime window = LocalDateTime.now().minusMonths(deviceLinkProperties.getApprovalWindowMonths());
                    return deviceLinkRequestRepository.findRecentRequestsForStudent(request.getStudentIndex(), window)
                            .collectList()
                            .flatMap(recentRequests -> {
                                if (recentRequests.size() > 1) {
                                    log.warn("Flagging device link request for student {} due to recent activity.", request.getStudentIndex());
                                    return deviceManagementService.flagDeviceLinkRequest(request)
                                            .then(emailService.sendDeviceLinkFlaggedNotification(request));
                                } else {
                                    log.info("Auto-approving device link request for student {}.", request.getStudentIndex());
                                    return deviceManagementService.approveDeviceLink(request);
                                }
                            });
                })
                .doOnComplete(() -> log.info("Finished scheduled job: Process Pending Device Link Requests"))
                .subscribe();
    }
}
