package mk.ukim.finki.attendanceappserver.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.NonNull;
import lombok.Setter;

import java.time.LocalDate;

@Setter
@Getter
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ProfessorClassSessionFilterDTO {

    @NonNull
    private String professorId;
    private String subjectId;
    private LocalDate date;
    private String week;
    private String month;
}
