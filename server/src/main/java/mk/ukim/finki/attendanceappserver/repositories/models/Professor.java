package mk.ukim.finki.attendanceappserver.repositories.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("professor")
public class Professor {

    @Id
    @NonNull
    @Column("id")
    private String id;

    @NonNull
    @Column("email")
    private String email;

    @NonNull
    @Column("name")
    private String name;

    @Column("title")
    private String title;

    @Column("ordering_rank")
    private int orderingRank;

    @Column("office_name")
    private String officeName;
}
