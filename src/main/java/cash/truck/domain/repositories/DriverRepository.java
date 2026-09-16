package cash.truck.domain.repositories;

import cash.truck.domain.entities.Driver;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

@Repository
public interface DriverRepository extends JpaRepository<Driver, Long>, JpaSpecificationExecutor<Driver> {
    Page<Driver> findAll(Specification<Driver> specification, Pageable pageable);
    java.util.Optional<Driver> findByOwnerIdAndDocumentNumber(Long ownerId, String documentNumber);
    java.util.Optional<Driver> findFirstByUserId(Integer userId);
    java.util.List<Driver> findByOwnerId(Long ownerId);

    /** Conductores que cumplen anos en alguno de los dias dados, como MM-dd. */
    @org.springframework.data.jpa.repository.Query(value = """
            SELECT d.id FROM driver d
             WHERE d.birthdate IS NOT NULL
               AND DATE_FORMAT(d.birthdate, '%m-%d') IN (:monthDays)
            """, nativeQuery = true)
    java.util.List<Number> findIdsByBirthdayIn(
            @org.springframework.data.repository.query.Param("monthDays") java.util.Collection<String> monthDays);
    java.util.Optional<Driver> findFirstByCellPhoneInAndUserIsNotNull(java.util.List<String> cellPhones);

    /** Validaciones de unicidad del registro publico. */
    boolean existsByDocumentNumber(String documentNumber);

    boolean existsByEmailIgnoreCase(String email);

    boolean existsByCellPhoneIn(java.util.List<String> cellPhones);

    /**
     * Conductores cuya licencia, segun su propia ficha, vence ese dia y que no
     * tienen el documento de licencia activo en document_file. Cuando el
     * documento existe manda su fecha: asi el conductor no recibe dos avisos
     * por la misma licencia, uno por cada fuente.
     *
     * Devuelve solo ids: la entidad trae columnas @Formula que una consulta
     * nativa no puede llenar.
     */
    @org.springframework.data.jpa.repository.Query(value = """
            SELECT d.id
              FROM driver d
             WHERE d.license_expiry = :expiryDate
               AND NOT EXISTS (SELECT 1
                                 FROM document_file df
                                 JOIN document_file_type t ON t.id = df.document_file_type_id
                                WHERE df.driver_id = d.id
                                  AND df.is_active = TRUE
                                  AND t.name = :licenseTypeName
                                  AND t.applies_to = 'DRIVER')
            """, nativeQuery = true)
    java.util.List<Number> findIdsByLicenseExpiryWithoutLicenseDocument(
            @org.springframework.data.repository.query.Param("expiryDate") java.time.LocalDate expiryDate,
            @org.springframework.data.repository.query.Param("licenseTypeName") String licenseTypeName);
}
