package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Formula;
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

    /**
     * Vehiculo asignado al conductor. La asignacion se guarda del lado del
     * vehiculo (vehicle.current_driver_id), asi que aqui se resuelve leyendo esa
     * relacion al reves; queda nulo cuando el conductor no tiene vehiculo.
     *
     * Va como @Formula y no como relacion mapeada para que el listado no
     * arrastre la entidad Vehicle completa —que trae owners y driver en EAGER—
     * cuando lo unico que necesita el cliente es el id y la placa.
     *
     * Solo cuentan los vehiculos en estado Activo: uno vendido, inactivo o en
     * mantenimiento puede conservar su current_driver_id y no representa una
     * asignacion vigente.
     *
     * Nada impide en BD que dos vehiculos apunten al mismo conductor; el ORDER
     * BY fija cual gana en vez de dejarlo al azar del motor.
     */
    @Formula("(SELECT v.id FROM vehicle v WHERE v.current_driver_id = id AND v.status = 'Activo' ORDER BY v.id LIMIT 1)")
    private Long currentVehicleId;

    @Formula("(SELECT v.plate FROM vehicle v WHERE v.current_driver_id = id AND v.status = 'Activo' ORDER BY v.id LIMIT 1)")
    private String currentVehiclePlate;

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

    /**
     * El celular se captura con espacios (314 723 57 39) pero se almacena sin
     * ellos. Al normalizar aqui y no en el caso de uso, la regla aplica por
     * igual a cualquier via que asigne el celular, incluido el JSON entrante.
     */
    public void setCellPhone(String cellPhone) {
        this.cellPhone = cellPhone == null ? null : cellPhone.replaceAll("\\s", "");
    }
}
