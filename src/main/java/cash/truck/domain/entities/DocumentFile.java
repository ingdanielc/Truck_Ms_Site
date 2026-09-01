package cash.truck.domain.entities;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.Date;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/**
 * Documento archivado de un vehiculo, un conductor o un propietario.
 *
 * Cuelga de exactamente una de las tres entidades; las otras dos referencias
 * van nulas y la base lo verifica con un CHECK. La columna generada active_key
 * no se mapea: existe solo para que el indice unico permita un documento activo
 * por entidad y tipo, dejando el historico inactivo sin limite.
 */
@Getter
@Setter
@Entity
@Table(name = "document_file")
public class DocumentFile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "document_file_type_id", nullable = false)
    private Integer documentFileTypeId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "document_file_type_id", referencedColumnName = "id", insertable = false, updatable = false)
    private DocumentFileType documentFileType;

    @Column(name = "vehicle_id")
    private Long vehicleId;

    @Column(name = "driver_id")
    private Long driverId;

    @Column(name = "owner_id")
    private Long ownerId;

    @Column(name = "document_number", length = 100)
    private String documentNumber;

    /** Aseguradora o CDA que lo expide. */
    @Column(name = "issuer", length = 150)
    private String issuer;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    @Column(name = "issue_date")
    private LocalDate issueDate;

    /** Nulo cuando el tipo no vence, como la tarjeta de propiedad. */
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    @Column(name = "expiry_date")
    private LocalDate expiryDate;

    /** Nulo cuando se registro solo para recordar el vencimiento, sin cargar el archivo. */
    @Column(name = "file_url", length = 255)
    private String fileUrl;

    @Lob
    @Column(name = "observations")
    private String observations;

    /** Al renovar, el anterior queda inactivo en vez de desaparecer. */
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "creation_date", insertable = false, updatable = false)
    private Date creationDate;

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "update_date", insertable = false, updatable = false)
    private Date updateDate;
}
