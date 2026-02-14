package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "biometric_data")
public class BiometricData {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @OneToOne
    @JoinColumn(name = "partner_id", unique = true, nullable = false)
    private Partner partnerId;

    @Lob
    @Column(name = "fingerprint", nullable = false)
    private byte[] fingerprint;
}
