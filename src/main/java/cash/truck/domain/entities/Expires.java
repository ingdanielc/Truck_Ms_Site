package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "expires")
public class Expires {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "expires_id")
    private Long expiresId;
    @Column(name = "expires_name")
    private String expiresName;
}
