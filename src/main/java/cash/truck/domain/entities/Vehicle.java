package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.annotations.Formula;

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
    @Column(name = "photo")
    private String photo;

    @Formula("(SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END FROM trip t WHERE t.vehicle_id = id AND t.status = 'En Curso')")
    private Boolean occupied;

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

    /**
     * Odometro con que el vehiculo entra a CashTruck. Opcional: arranca en 0 y
     * el propietario lo corrige cuando conoce el dato real.
     *
     * Es el punto de partida de totalKm, no un dato suelto: un camion que llega
     * con 300.000 km encima no tiene el odometro en cero por haber entrado hoy
     * a la aplicacion.
     */
    @Column(name = "initial_km", precision = 12, scale = 2)
    private BigDecimal initialKm = BigDecimal.ZERO;

    /**
     * Odometro del vehiculo: el kilometraje inicial mas lo recorrido en los
     * viajes registrados en CashTruck.
     *
     * Va como @Formula, igual que occupied, para que la card lo pinte con la
     * misma consulta que ya trae el vehiculo, sin una llamada extra por fila.
     *
     * Solo suman los viajes ya terminados —Completado y Pendiente—, que son los
     * dos estados en que el recorrido ya se hizo. Los otros tres quedan fuera
     * porque no hay kilometros ciertos que contar: uno En Curso todavia no
     * termina, uno Planeado no arranco y uno Cancelado nunca rodo.
     *
     * Un viaje sin distancia suma cero y no anula el total, y el COALESCE de
     * initial_km cubre las filas anteriores a esa columna.
     */
    @Formula("(COALESCE(initial_km, 0) + (SELECT COALESCE(SUM(t.distance_km), 0) FROM trip t WHERE t.vehicle_id = id AND t.status IN ('Completado', 'Pendiente')))")
    private BigDecimal totalKm;

    @Column(name = "current_driver_id")
    private Integer currentDriverId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "current_driver_id", referencedColumnName = "id", insertable = false, updatable = false)
    private Driver driver;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", columnDefinition = "ENUM('Activo', 'En Mantenimiento', 'Inactivo', 'Vendido')")
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
        Inactivo,
        Vendido
    }
}