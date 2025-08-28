package mk.ukim.finki.attendanceappserver.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class DeviceLinkRequestDTO {
    private String deviceId;
    private String deviceName;
    private String deviceOs;
}
