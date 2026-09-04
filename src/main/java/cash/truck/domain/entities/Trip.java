package cash.truck.domain.entities;

import cash.truck.domain.enums.TripLegEnum;
import cash.truck.domain.enums.TripTypeEnum;
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

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "vehicle_id", referencedColumnName = "id", insertable = false, updatable = false)
    private Vehicle vehicle;

    @Column(name = "driver_id", nullable = false)
    private Long driverId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "driver_id", referencedColumnName = "id", insertable = false, updatable = false)
    private Driver driver;

    // Obligatorio solo si tripType != VACIO
    @Column(name = "manifest_number", length = 100)
    private String manifestNumber;

    @Column(name = "number_trip", length = 50, nullable = false)
    private String numberTrip;

    @Column(name = "company", length = 100)
    private String company;

    @Column(name = "origin_id", nullable = false, length = 100)
    private String originId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "origin_id", referencedColumnName = "id", insertable = false, updatable = false)
    private City origin;

    @Column(name = "destination_id", nullable = false, length = 100)
    private String destinationId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "destination_id", referencedColumnName = "id", insertable = false, updatable = false)
    private City destination;

    // Destino de regreso: se usa cuando tripType == REDONDO
    @Column(name = "return_destination_id", length = 100)
    private String returnDestinationId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "return_destination_id", referencedColumnName = "id", insertable = false, updatable = false)
    private City returnDestination;

    @Column(name = "start_date", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date startDate;

    @Column(name = "end_date")
    @Temporal(TemporalType.TIMESTAMP)
    private Date endDate;

    @Column(name = "number_of_days", nullable = false)
    private Integer numberOfDays;

    @Column(name = "load_type", length = 100)
    private String loadType;

    /**
     * Kilometros del viaje, tal como los informa el front al guardarlo. Se
     * espera que incluyan el tramo de regreso cuando el viaje es REDONDO.
     *
     * El backend no lo calcula ni lo estima: solo lo persiste. Es el dato con
     * que se arma el odometro del vehiculo (Vehicle.totalKm).
     *
     * Nulo es "todavia sin kilometraje" —viajes anteriores a este campo, o un
     * guardado que no lo trajo—, distinto de 0, que seria un viaje sin
     * recorrido. Un nulo suma cero al odometro y se corrige informandolo.
     */
    @Column(name = "distance_km", precision = 10, scale = 2)
    private BigDecimal distanceKm;

    @Column(name = "freight", nullable = false, precision = 15, scale = 2)
    private BigDecimal freight = new BigDecimal("0.00");

    @Column(name = "advance_payment", nullable = false, precision = 15, scale = 2)
    private BigDecimal advancePayment = new BigDecimal("0.00");

    // Campo calculado en BD
    @Column(name = "balance", insertable = false, updatable = false, precision = 15, scale = 2)
    private BigDecimal balance;

    @Column(name = "paid_balance", nullable = false)
    private Boolean paidBalance = false;

    @Column(name = "status")
    private String status;

    // Si el cliente no lo envía se persiste como CARGADO
    @Enumerated(EnumType.STRING)
    @Column(name = "trip_type", length = 10)
    private TripTypeEnum tripType = TripTypeEnum.CARGADO;

    // Tramo activo: solo se acepta cuando tripType == REDONDO
    @Enumerated(EnumType.STRING)
    @Column(name = "current_leg", length = 10)
    private TripLegEnum currentLeg;

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "creation_date", insertable = false, updatable = false)
    private Date creationDate;

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "update_date", insertable = false, updatable = false)
    private Date updateDate;

}