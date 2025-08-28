package mk.ukim.finki.attendanceappserver.domain.models;

import lombok.Data;
import lombok.NonNull;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Column;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table("room")
public class Room {

    @Id
    @NonNull
    @Column("name")
    private String name;

    @Column("capacity")
    private int capacity;

    @Column("equipment_description")
    private String equipmentDescription;

    @Column("location_description")
    private String locationDescription;

    @Column("type")
    private String type;
}
