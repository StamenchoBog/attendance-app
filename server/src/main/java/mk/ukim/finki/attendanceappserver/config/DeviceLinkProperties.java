package mk.ukim.finki.attendanceappserver.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "app.device-linking")
@Getter
@Setter
public class DeviceLinkProperties {

    /**
     * The time window in months to check for previous device link requests.
     * If a student has another request within this window, the new request will be flagged.
     * Default is 6 months.
     */
    private int approvalWindowMonths = 6;

    /**
     * The email address to which flagged device link request notifications will be sent.
     */
    private String notificationEmail = "it-support@finki.ukim.mk";

}
