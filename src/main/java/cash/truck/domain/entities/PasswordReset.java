package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.util.Date;

/**
 * Solicitud de recuperacion de contrasena: a que usuario pertenece, a que celular
 * se envio el codigo, cuando expira y en que punto del flujo va.
 *
 * El codigo se guarda cifrado (SHA-512, igual que la contrasena) porque mientras
 * esta vigente equivale a una credencial.
 */
@Getter
@Setter
@Entity
@Table(name = "password_reset")
public class PasswordReset {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

    @Column(name = "phone", length = 20)
    private String phone;

    @Column(name = "code", length = 128, nullable = false)
    private String code;

    @Column(name = "status", length = 20, nullable = false)
    private String status;

    @Column(name = "attempts", nullable = false)
    private Integer attempts = 0;

    /** Se emite al validar el codigo y es lo unico que autoriza el cambio de contrasena. */
    @Column(name = "reset_token", length = 64)
    private String resetToken;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "expiration_date", nullable = false)
    private Date expirationDate;

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "creation_date", nullable = false, updatable = false)
    private Date creationDate;

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "update_date", nullable = false)
    private Date updateDate;
}
