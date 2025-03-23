package mk.ukim.finki.attendanceappserver.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.NonNull;
import lombok.Setter;

@Setter
@Getter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ClassSessionFilterDTO {

    @NonNull
    private String professorId;

    private String subjectId;

    private String date;

    private String week;
    private String month;
}
