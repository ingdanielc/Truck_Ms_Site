package cash.truck.domain.entities;

import cash.truck.domain.enums.DocumentHolderEnum;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/**
 * Catalogo de tipos de documento archivado. No confundir con DocumentType, que
 * es el tipo de identificacion de una persona (owner.documentTypeId): aquel es
 * un atributo, este describe un papel con emisor, vencimiento y escaneo.
 */
@Getter
@Setter
@Entity
@Table(name = "document_file_type")
public class DocumentFileType {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Integer id;

    @Column(name = "name", nullable = false, length = 80)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(name = "applies_to", nullable = false)
    private DocumentHolderEnum appliesTo;

    /** El formulario pide la fecha solo cuando este tipo la exige. */
    @Column(name = "requires_expiry", nullable = false)
    private Boolean requiresExpiry = false;

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
