package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.util.Date;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "partner")
public class Partner {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "photo")
    private String photo;

    @Column(name = "document_type_id", nullable = false)
    private Long documentTypeId;

    @Column(name = "document_number", unique = true, length = 20, nullable = false)
    private String documentNumber;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    @Column(name = "cell_phone", length = 15)
    private String cellPhone;

    @Column(name = "email", length = 100)
    private String email;

    @Column(name = "city_id")
    private Long cityId;

    @Column(name = "address", length = 255)
    private String address;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "birthdate")
    private Date birthdate;

    @Column(name = "age")
    private Integer age;

    @Column(name = "gender_id")
    private Long genderId;

    @Column(name = "status")
    private String status;

    @OneToMany(mappedBy = "partnerId", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<PartnerMembership> partnerMembership;

    @Transient
    private Date accessTime;

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "creation_date", nullable = false, updatable = false)
    private Date creationDate;

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "update_date", nullable = false)
    private Date updateDate;
}
