package mk.ukim.finki.attendanceappserver.dto.generic;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class APIResponse<T> {
    private T data;
    private boolean success;
    private String message;
    private int statusCode;

    public static <T> APIResponse<T> success(T data) {
        return new APIResponse<>(data, true, null, HttpStatus.OK.value());
    }

    public static <T> APIResponse<T> error(String message, int statusCode) {
        return new APIResponse<>(null, false, message, statusCode);
    }
}