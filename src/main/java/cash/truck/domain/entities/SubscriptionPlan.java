package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Date;

/**
 * Tarifa con la que se cobra una renovacion.
 *
 * Hay una fila por periodo de precios y no una sola fila editable: subir el
 * precio inserta una tarifa nueva y cierra la anterior. Asi un pago del ano
 * pasado sigue pudiendo explicar contra que valores se cobro, que es lo que se
 * perderia si el precio viviera en un unico registro que se sobrescribe.
 */
@Getter
@Setter
@Entity
@Table(name = "subscription_plan")
public class SubscriptionPlan {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    /** Lo que cuesta el ano incluyendo los primeros includedVehicles vehiculos. */
    @Column(name = "annual_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal annualPrice;

    @Column(name = "additional_vehicle_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal additionalVehiclePrice;

    /**
     * Cuantos vehiculos cubre la anualidad antes de cobrar adicionales. Hoy es
     * uno, pero se deja parametrizado porque es justo el numero que cambia con
     * una promocion.
     */
    @Column(name = "included_vehicles", nullable = false)
    private Integer includedVehicles;

    /** Duracion de la renovacion. Doce hoy; el campo evita cablear el ano. */
    @Column(name = "months", nullable = false)
    private Integer months;

    @Column(name = "valid_from", nullable = false)
    private LocalDate validFrom;

    /** Nulo es la tarifa actual: la que todavia no se ha reemplazado. */
    @Column(name = "valid_to")
    private LocalDate validTo;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "creation_date", insertable = false, updatable = false)
    private Date creationDate;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "update_date", insertable = false, updatable = false)
    private Date updateDate;
}
