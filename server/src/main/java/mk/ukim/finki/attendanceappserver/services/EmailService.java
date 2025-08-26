package mk.ukim.finki.attendanceappserver.services;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import mk.ukim.finki.attendanceappserver.config.DeviceLinkProperties;
import mk.ukim.finki.attendanceappserver.repositories.models.DeviceLinkRequest;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

@Service
@AllArgsConstructor
@Slf4j
public class EmailService {

    private final DeviceLinkProperties deviceLinkProperties;

    public Mono<Void> sendDeviceLinkFlaggedNotification(DeviceLinkRequest request) {
        return Mono.fromRunnable(() -> {
            log.info("--- SIMULATING EMAIL NOTIFICATION ---");
            log.info("Recipient: {}", deviceLinkProperties.getNotificationEmail());
            log.info("Subject: [Attendance App] Device Link Request Flagged for Review");
            log.info("Body: {}", buildEmailBody(request));
            log.info("--- END OF SIMULATED EMAIL ---");
        }).then();
    }

    private String buildEmailBody(DeviceLinkRequest request) {
        return String.format(
                "A device link request has been flagged for manual review.\n\n" +
                "Student Index: %s\n" +
                "New Device ID: %s\n" +
                "New Device Name: %s\n" +
                "New Device OS: %s\n" +
                "Request Time: %s\n\n" +
                "Reason for Flagging: The student has had another device change request within the last %d months.\n\n" +
                "Please review this request in the admin panel.",
                request.getStudentIndex(),
                request.getDeviceId(),
                request.getDeviceName(),
                request.getDeviceOs(),
                request.getRequestTimestamp().toString(),
                deviceLinkProperties.getApprovalWindowMonths()
        );
    }
}
