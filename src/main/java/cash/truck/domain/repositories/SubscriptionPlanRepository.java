package cash.truck.domain.repositories;

import cash.truck.domain.entities.SubscriptionPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface SubscriptionPlanRepository extends JpaRepository<SubscriptionPlan, Integer> {

    /**
     * La tarifa aplicable en una fecha.
     *
     * Devuelve lista y no Optional porque nada en la base impide que queden dos
     * filas abiertas a la vez; ordenar por vigencia descendente hace que gane
     * la mas reciente en lugar de reventar. Quien llama toma la primera.
     */
    @Query("""
            SELECT p FROM SubscriptionPlan p
             WHERE p.validFrom <= :date
               AND (p.validTo IS NULL OR p.validTo >= :date)
             ORDER BY p.validFrom DESC, p.id DESC
            """)
    List<SubscriptionPlan> findApplicable(@Param("date") LocalDate date);
}
