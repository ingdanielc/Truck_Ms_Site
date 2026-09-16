package cash.truck.domain.repositories;

import cash.truck.domain.entities.Notification;
import cash.truck.domain.entities.Roles;
import cash.truck.domain.entities.Users;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository
        extends JpaRepository<Notification, Long> {

    Page<Notification> findAll(Specification<Notification> specification, Pageable pageable);

    List<Notification> findByTargetUserOrTargetRole(Users targetUser, Roles targetRole);

    List<Notification> findByEventType(String eventType);

    List<Notification> findByIsRead(Boolean isRead);

    /**
     * Antirrepeticion de los avisos de inactividad. El planificador pasa cada
     * hora sobre las mismas filas mientras la condicion siga vigente, asi que
     * sin esto un viaje sin gastos generaria un aviso por hora.
     *
     * Cuenta tambien las borradas: que el propietario haya limpiado la bandeja
     * no es razon para volver a avisarle lo mismo.
     */
    boolean existsByEventTypeAndReferenceId(String eventType, Long referenceId);

    /**
     * Antirrepeticion del aviso de viaje sin gastos: se vuelve a avisar solo
     * si no hay aviso posterior a la ultima actividad del viaje. Asi un viaje
     * que registro gastos y despues volvio a quedarse quieto se avisa otra vez,
     * pero un mismo silencio no se avisa cada hora.
     */
    boolean existsByEventTypeAndReferenceIdAndCreationDateAfter(String eventType, Long referenceId,
            java.util.Date creationDate);

    /**
     * Aseo de la bandeja, por lotes: borra las marcadas como borradas antes de
     * deletedBefore y cualquiera creada antes de createdBefore.
     *
     * Los tipos excluidos no se tocan nunca: su fila es la marca de que el
     * aviso ya salio (existsByEventTypeAndReferenceId), y borrarla haria que un
     * viaje que siga en la misma condicion se avisara otra vez.
     *
     * Transaccion propia por lote: cada llamada confirma lo suyo y un lote que
     * falle no revierte los anteriores ni retiene bloqueos sobre toda la tabla.
     */
    @org.springframework.data.jpa.repository.Modifying
    @org.springframework.transaction.annotation.Transactional
    @org.springframework.data.jpa.repository.Query(value = """
            DELETE FROM notification
             WHERE event_type NOT IN (:excludedEventTypes)
               AND ((is_deleted = TRUE AND creation_date < :deletedBefore)
                    OR creation_date < :createdBefore)
             LIMIT :batchSize
            """, nativeQuery = true)
    int deleteExpiredBatch(
            @org.springframework.data.repository.query.Param("excludedEventTypes") java.util.Collection<String> excludedEventTypes,
            @org.springframework.data.repository.query.Param("deletedBefore") java.util.Date deletedBefore,
            @org.springframework.data.repository.query.Param("createdBefore") java.util.Date createdBefore,
            @org.springframework.data.repository.query.Param("batchSize") int batchSize);
}
