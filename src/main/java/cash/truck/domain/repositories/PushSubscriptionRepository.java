package cash.truck.domain.repositories;

import cash.truck.domain.entities.PushSubscription;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;
import java.util.Optional;

@Repository
public interface PushSubscriptionRepository extends JpaRepository<PushSubscription, Long> {

    /**
     * La suscripcion se identifica por su endpoint, no por el usuario: es lo que
     * permite que el alta sea un upsert y que un celular prestado se reasigne al
     * conductor que entra en vez de duplicarse.
     */
    Optional<PushSubscription> findByEndpointHash(String endpointHash);

    /** Punto de partida de todo envio. */
    List<PushSubscription> findByUserIdAndIsActiveTrue(Integer userId);

    /**
     * Aseo: las que el push service ya rechazo definitivamente y las que llevan
     * mucho tiempo inactivas. Se borra en bloque porque son filas muertas, sin
     * valor historico.
     */
    @Modifying
    @Query("DELETE FROM PushSubscription s WHERE s.failureCount > :maxFailures "
            + "OR (s.isActive = false AND s.updateDate < :inactiveBefore)")
    int deleteDeadSubscriptions(@Param("maxFailures") int maxFailures,
                                @Param("inactiveBefore") Date inactiveBefore);
}
