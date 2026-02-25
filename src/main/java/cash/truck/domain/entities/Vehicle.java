package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Getter
@Setter
@Entity
@Table(name = "vehicle")
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Lob
    @Column(name = "photo", columnDefinition = "LONGTEXT")
    private String photo;

    @Transient
    private Long ownerId;

    @OneToMany(fetch = FetchType.EAGER)
    @JoinColumn(name = "vehicle_id", referencedColumnName = "id", insertable = false, updatable = false)
    private List<VehicleOwner> owners;

    @Column(name = "plate", nullable = false, length = 10, unique = true)
    private String plate;

    @Column(name = "vehicle_brand_id", nullable = false)
    private Integer vehicleBrandId;

    @Column(name = "model", nullable = false, length = 50)
    private String model;

    @Column(name = "year", nullable = false)
    private Integer year;

    @Column(name = "color", length = 30)
    private String color;

    @Column(name = "engine_number", length = 50)
    private String engineNumber;

    @Column(name = "chassis_number", length = 50)
    private String chassisNumber;

    @Column(name = "number_of_axles", length = 50)
    private String numberOfAxles;

    @Column(name = "current_driver_id")
    private Integer currentDriverId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "current_driver_id", referencedColumnName = "id", insertable = false, updatable = false)
    private Driver driver;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", columnDefinition = "ENUM('Activo','En Mantenimiento','Inactivo')")
    private Status status = Status.Activo;

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "creation_date", insertable = false, updatable = false)
    private Date creationDate;

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "update_date", insertable = false, updatable = false)
    private Date updateDate;

    public enum Status {
        Activo,
        En_Mantenimiento,
        Inactivo
    }
}