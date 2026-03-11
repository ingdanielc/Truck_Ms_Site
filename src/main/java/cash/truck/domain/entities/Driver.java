package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Entity
@Table(name = "driver")
@Getter
@Setter
public class Driver {

    @Transient
    private String password;

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Lob
    @Column(name = "photo")
    private String photo;

    @Column(name = "document_type_id", nullable = false)
    private Integer documentTypeId;

    @Column(name = "document_number", nullable = false, length = 20, unique = true)
    private String documentNumber;

    @Column(name = "name", nullable = false, length = 150)
    private String name;

    @Column(name = "email", nullable = false, length = 100, unique = true)
    private String email;

    @Column(name = "cell_phone", nullable = false, length = 20)
    private String cellPhone;

    @Column(name = "city_id")
    private Integer cityId;

    @Column(name = "gender_id")
    private Integer genderId;

    @Column(name = "birthdate")
    private Date birthdate;

    // Campo calculado en BD (edad virtual)
    @Column(name = "age", insertable = false, updatable = false)
    private Integer age;

    @Column(name = "salary_type_id")
    private Integer salaryTypeId;

    @Column(name = "salary")
    private Integer salary;

    @Column(name = "license_category", nullable = false, length = 5)
    private String licenseCategory;

    @Column(name = "license_number", nullable = false, length = 50)
    private String licenseNumber;

    @Column(name = "license_expiry", nullable = false)
    private Date licenseExpiry;

    @OneToOne
    @JoinColumn(name = "user_id", referencedColumnName = "id")
    private Users user;

    @Column(name = "owner_id", nullable = false)
    private Long ownerId;

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "creation_date", insertable = false, updatable = false)
    private Date creationDate;

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "update_date", insertable = false, updatable = false)
    private Date updateDate;
}