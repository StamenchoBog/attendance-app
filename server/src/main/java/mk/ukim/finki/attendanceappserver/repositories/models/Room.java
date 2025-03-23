package mk.ukim.finki.attendanceappserver.repositories.models;

import jakarta.persistence.EntityListeners;
import jakarta.persistence.Column;
import lombok.Data;
import lombok.NonNull;
import mk.ukim.finki.attendanceappserver.exceptions.entity.PreventAnyUpdate;
import org.springframework.data.annotation.Id;
import org.springframework.data.relational.core.mapping.Table;

@Data
@Table(name = "room")
@EntityListeners(PreventAnyUpdate.class)
public class Room {

    @Id
    @NonNull
    @Column(name = "name")
    private String name;

    @Column(name = "capacity")
    private int capacity;

    @Column(name = "equipment_description")
    private String equipmentDescription;

    @Column(name = "location_description")
    private String locationDescription;

    @Column(name = "type")
    private String type;
}
