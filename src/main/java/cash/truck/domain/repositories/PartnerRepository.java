package cash.truck.domain.repositories;

import cash.truck.domain.entities.Partner;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PartnerRepository extends JpaRepository<Partner, Long> {
    Optional<Partner> findByDocumentTypeIdAndDocumentNumber(Long documentTypeId, String documentNumber);
    Page<Partner> findAll(Specification<Partner> specification, Pageable pageable);

    @Query("SELECT p FROM Partner p WHERE MONTH(p.birthdate) = MONTH(CURRENT_DATE) AND DAY(p.birthdate) = DAY(CURRENT_DATE)")
    List<Partner> findPartnersWithBirthdayToday();

    @Query("SELECT p, (SELECT MAX(ac.accessTime) as accessTime FROM AccessControl ac WHERE ac.partner = p) " +
            " FROM Partner p " +
            "WHERE p.status = 'Active' " +
            "AND NOT EXISTS ( " +
            "    SELECT ac FROM AccessControl ac " +
            "    WHERE ac.partner = p " +
            "    AND ac.accessTime >= :daysAgo " +
            ")")
    List<Object[]> findInactivePartners(@Param("daysAgo") LocalDateTime daysAgo);
}
