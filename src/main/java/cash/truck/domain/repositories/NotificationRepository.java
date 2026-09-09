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
}
