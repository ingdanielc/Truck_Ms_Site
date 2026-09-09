package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Date;

/**
 * Un intento de renovacion y su desenlace.
 *
 * Queda fila aunque el pago se rechace: eso es lo que permite responder por que
 * un propietario reclama que ya pago. La fila nace Pendiente y solo cambia la
 * fecha de suscripcion cuando un administrador la confirma, porque la
 * comprobacion del pago es manual y no hay pasarela que la certifique.
 *
 * Los importes se copian del plan en vez de leerse de el al consultar: una
 * factura que cambia de valor cuando sube la tarifa no sirve como respaldo.
 */
@Getter
@Setter
@Entity
@Table(name = "subscription_payment")
public class SubscriptionPayment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "owner_id", nullable = false)
    private Long ownerId;

    /**
     * Nombre y celular del propietario para la bandeja del administrador.
     *
     * Van como formula y no como relacion a Owner porque esa entidad arrastra
     * la foto, que es un LOB en base64: serializarla en cada fila del listado
     * multiplicaria el tamano de la respuesta por algo que nadie mira ahi.
     */
    @org.hibernate.annotations.Formula("(SELECT o.name FROM owner o WHERE o.id = owner_id)")
    private String ownerName;

    @org.hibernate.annotations.Formula("(SELECT o.cell_phone FROM owner o WHERE o.id = owner_id)")
    private String ownerCellPhone;

    @Column(name = "plan_id", nullable = false)
    private Integer planId;

    /**
     * Cupo cobrado: copia de owner.maxVehicles al cotizar. Si el propietario
     * amplia el cupo despues, este pago sigue diciendo por cuantos vehiculos
     * pago realmente.
     */
    @Column(name = "vehicle_count", nullable = false)
    private Integer vehicleCount;

    @Column(name = "additional_vehicles", nullable = false)
    private Integer additionalVehicles;

    /**
     * Anualidades compradas de una vez. Multiplica el total y los meses que se
     * suman al vencimiento; no existe el valor cero ni fracciones de ano.
     */
    @Column(name = "years", nullable = false)
    private Integer years;

    @Column(name = "annual_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal annualPrice;

    @Column(name = "additional_vehicle_price", nullable = false, precision = 15, scale = 2)
    private BigDecimal additionalVehiclePrice;

    @Column(name = "total_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "payment_method", nullable = false)
    private String paymentMethod;

    /**
     * Numero de transaccion transcrito del comprobante. No es unico a
     * proposito: ni Nequi ni Bancolombia garantizan el formato, y un error de
     * tecleo no puede impedir registrar un pago que si existio.
     */
    @Column(name = "reference", length = 100)
    private String reference;

    /** URL que devuelve /common/upload-document; el archivo se sube antes. */
    @Column(name = "receipt_url", length = 255)
    private String receiptUrl;

    @Column(name = "status", nullable = false)
    private String status;

    @Column(name = "rejection_reason", length = 255)
    private String rejectionReason;

    /**
     * Fecha de suscripcion antes de aplicar el pago. Permite deshacer una
     * confirmacion equivocada sin tener que adivinar a donde volver.
     */
    @Column(name = "previous_end_date")
    private LocalDate previousEndDate;

    @Column(name = "new_end_date")
    private LocalDate newEndDate;

    @Column(name = "reviewed_by_user_id")
    private Integer reviewedByUserId;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "reviewed_at")
    private Date reviewedAt;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "creation_date", insertable = false, updatable = false)
    private Date creationDate;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "update_date", insertable = false, updatable = false)
    private Date updateDate;
}
