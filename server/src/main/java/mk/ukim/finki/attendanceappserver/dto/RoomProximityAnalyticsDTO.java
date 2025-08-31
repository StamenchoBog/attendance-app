package mk.ukim.finki.attendanceappserver.dto;

import lombok.Builder;
import lombok.Data;
import mk.ukim.finki.attendanceappserver.domain.models.ProximityVerificationLog;

import java.util.List;

@Data
@Builder
public class RoomProximityAnalyticsDTO {
    private String roomId;
    private Integer totalVerifications;
    private Integer successfulVerifications;
    private Double averageDistance;
    private List<ProximityVerificationLog> verificationLogs;
}
