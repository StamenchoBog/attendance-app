package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.annotation.Id;

@Data
@Table(name = "professor")
@EntityListeners(PreventAnyUpdate.class)
public class Professor {

    @Id
    @NonNull
    @Column(name = "id")
    private String id;

    @NonNull
    @Column(name = "email", unique = true)
    private String email;

    @NonNull
    @Column(name = "name")
    private String name;

    @Column(name = "title")
    private String title;

    @Column(name = "ordering_rank")
    private int orderingRank;

    @Column(name = "office_name")
    private String officeName;
}
