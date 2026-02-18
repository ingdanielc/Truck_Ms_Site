package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.math.BigDecimal;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;


@Getter
@Setter
@Entity
@Table(name = "trip")
public class Trip {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "vehicle_id", nullable = false)
    private Long vehicleId;

    @Column(name = "driver_id", nullable = false)
    private Long driverId;

    @Column(name = "manifest_number", nullable = false, length = 100)
    private String manifestNumber;

    @Column(name = "company", length = 100)
    private String company;

    @Column(name = "origin", nullable = false, length = 100)
    private String origin;

    @Column(name = "destination", nullable = false, length = 100)
    private String destination;

    @Column(name = "start_date", nullable = false)
    private Date startDate;

    @Column(name = "end_date")
    private Date endDate;

    @Column(name = "number_of_days", nullable = false)
    private Integer numberOfDays;

    @Column(name = "load_type", length = 100)
    private String loadType;

    @Column(name = "freight", nullable = false, precision = 15, scale = 2)
    private BigDecimal freight = new BigDecimal("0.00");

    @Column(name = "advance_payment", nullable = false, precision = 15, scale = 2)
    private BigDecimal advancePayment = new BigDecimal("0.00");

    // Campo calculado en BD
    @Column(name = "balance", insertable = false, updatable = false, precision = 15, scale = 2)
    private BigDecimal balance;

    @Column(name = "paid_balance", nullable = false)
    private Boolean paidBalance = false;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", columnDefinition =
            "ENUM('Planeado','En Curso','Completado','Cancelado','Pendiente')")
    private Status status = Status.Planeado;

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "creation_date", insertable = false, updatable = false)
    private Date creationDate;

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "update_date", insertable = false, updatable = false)
    private Date updateDate;

    public enum Status {
        Planeado,
        En_Curso,
        Completado,
        Cancelado,
        Pendiente
    }
}