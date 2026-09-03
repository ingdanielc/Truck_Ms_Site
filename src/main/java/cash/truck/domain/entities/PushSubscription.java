package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/**
 * Suscripcion Web Push de un dispositivo.
 *
 * La suscripcion es por dispositivo y navegador, no por usuario: el mismo
 * propietario con celular, tablet y PC tiene tres filas. Por eso la identidad
 * de la fila es el endpoint y no el user_id.
 *
 * El endpoint se guarda en TEXT porque supera con holgura los 255 caracteres, y
 * la unicidad se apoya en endpointHash: MySQL no puede indexar una columna tan
 * larga (limite de 3072 bytes en la clave).
 */
@Getter
@Setter
@Entity
@Table(name = "push_subscription")
public class PushSubscription {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    /** Integer y no Long: users.id es INT. */
    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "endpoint", columnDefinition = "TEXT", nullable = false)
    private String endpoint;

    @Column(name = "endpoint_hash", length = 64, nullable = false, unique = true)
    private String endpointHash;

    /** Llave publica del dispositivo; con ella se cifra el payload. */
    @Column(name = "p256dh", length = 255, nullable = false)
    private String p256dh;

    @Column(name = "auth", length = 255, nullable = false)
    private String auth;

    @Column(name = "user_agent", length = 300)
    private String userAgent;

    /** Al revocarse el permiso o al cerrar sesion queda inactiva, no se borra. */
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "last_success_date")
    private Date lastSuccessDate;

    /** Fallos seguidos del push service. Se reinicia con cada entrega buena. */
    @Column(name = "failure_count", nullable = false)
    private Integer failureCount = 0;

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "creation_date", insertable = false, updatable = false)
    private Date creationDate;

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "update_date", insertable = false, updatable = false)
    private Date updateDate;
}
