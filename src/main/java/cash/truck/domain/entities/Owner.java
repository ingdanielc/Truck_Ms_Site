package cash.truck.domain.entities;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

@Getter
@Setter
@Entity
@Table(name = "owner")
@JsonIgnoreProperties({ "hibernateLazyInitializer", "handler" })
public class Owner {

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

    // Campo calculado en BD (no insertable ni actualizable)
    @Column(name = "age", insertable = false, updatable = false)
    private Integer age;

    @OneToOne
    @JoinColumn(name = "user_id", referencedColumnName = "id")
    private Users user;

    @org.hibernate.annotations.Formula("(SELECT COUNT(*) FROM vehicle_owner vo WHERE vo.owner_id = id)")
    private Integer vehicleCount;

    @org.hibernate.annotations.Formula("(SELECT COUNT(*) FROM driver d WHERE d.owner_id = id)")
    private Integer driverCount;

    @Column(name = "max_vehicles", nullable = false)
    private Integer maxVehicles;

    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "creation_date", insertable = false, updatable = false)
    private Date creationDate;

    @UpdateTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "update_date", insertable = false, updatable = false)
    private Date updateDate;
}