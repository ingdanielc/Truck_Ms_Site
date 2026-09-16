package cash.truck.domain.repositories;

import cash.truck.domain.entities.Owner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;

@Repository
public interface OwnerRepository extends JpaRepository<Owner, Long> {
    Page<Owner> findAll(Specification<Owner> specification, Pageable pageable);

    java.util.Optional<Owner> findByUserId(Integer userId);

    java.util.Optional<Owner> findFirstByCellPhoneInAndUserIsNotNull(java.util.List<String> cellPhones);

    /** Propietarios cuya suscripcion vence exactamente ese dia. */
    java.util.List<Owner> findBySubscriptionEndDate(java.time.LocalDate subscriptionEndDate);

    /**
     * Propietarios que cumplen anos en alguno de los dias dados, como MM-dd.
     * Solo ids: la entidad trae columnas @Formula que una consulta nativa no
     * puede llenar.
     */
    @org.springframework.data.jpa.repository.Query(value = """
            SELECT o.id FROM owner o
             WHERE o.birthdate IS NOT NULL
               AND DATE_FORMAT(o.birthdate, '%m-%d') IN (:monthDays)
            """, nativeQuery = true)
    java.util.List<Number> findIdsByBirthdayIn(
            @org.springframework.data.repository.query.Param("monthDays") java.util.Collection<String> monthDays);

    /** Validaciones de unicidad del registro publico. */
    boolean existsByDocumentNumber(String documentNumber);

    boolean existsByEmailIgnoreCase(String email);

    boolean existsByCellPhoneIn(java.util.List<String> cellPhones);
}
