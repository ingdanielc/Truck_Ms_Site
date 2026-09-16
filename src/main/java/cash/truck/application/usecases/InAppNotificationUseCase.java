package cash.truck.application.usecases;

import cash.truck.application.usecases.push.PushRecipientResolver;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.dtos.NotificationCreatedEvent;
import cash.truck.domain.entities.Notification;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.entities.Users;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.NotificationRepository;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.RolesRepository;
import cash.truck.domain.repositories.UsersRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Service
public class InAppNotificationUseCase {

    @Autowired
    private NotificationRepository notificationRepository;

    @Autowired
    private UsersRepository usersRepository;

    @Autowired
    private RolesRepository rolesRepository;

    @Autowired
    private OwnerRepository ownerRepository;

    @Autowired
    private DriverRepository driverRepository;

    @Autowired
    private PushRecipientResolver pushRecipientResolver;

    /**
     * El reparto por otros canales no se invoca desde aqui: se publica un evento
     * y quien escuche decide. Asi este caso de uso sigue sabiendo solo de la
     * notificacion interna, que es la fuente de verdad, y sumar un transporte
     * manana no obliga a tocarlo.
     */
    @Autowired
    private ApplicationEventPublisher eventPublisher;

    public List<Notification> getAllNotifications() {
        return notificationRepository.findAll();
    }

    public Notification saveNotification(Notification notification) {
        return notificationRepository.save(notification);
    }

    /**
     * Devuelve la fila guardada y no void: el envio push necesita el id real de
     * la notificacion para que, al abrirla desde el celular, el service worker
     * pueda marcarla como leida. Quien no lo necesite puede seguir ignorando el
     * retorno, que es lo que hacen hoy todos los llamadores.
     */
    public Notification createNotification(String eventType, String message, Integer targetRoleId,
            Integer targetUserId, Long ownerId, Long referenceId) {
        return createNotification(eventType, message, targetRoleId, targetUserId, ownerId, referenceId, null);
    }

    /**
     * Igual que la anterior, pero indicando quien hizo la accion. La
     * notificacion interna no cambia; solo el push deja fuera a ese usuario.
     */
    public Notification createNotification(String eventType, String message, Integer targetRoleId,
            Integer targetUserId, Long ownerId, Long referenceId, Integer actorUserId) {
        Notification notification = new Notification();
        notification.setEventType(eventType);
        notification.setMessage(message);
        notification.setReferenceId(referenceId);
        notification.setIsRead(false);
        notification.setIsDeleted(false);

        rolesRepository.findById(targetRoleId).ifPresent(notification::setTargetRole);
        if (targetUserId != null) {
            usersRepository.findById(targetUserId).ifPresent(notification::setTargetUser);
        }

        if (ownerId != null) {
            ownerRepository.findById(ownerId).ifPresent(notification::setOwner);
        }

        Notification saved = notificationRepository.save(notification);

        // Se publica despues de guardar y con los datos crudos: el oyente corre
        // tras el commit, fuera de esta sesion de Hibernate.
        eventPublisher.publishEvent(new NotificationCreatedEvent(saved.getId(), eventType, message,
                ownerId, referenceId, targetUserId, actorUserId));

        return saved;
    }

    /**
     * Crea una fila por destinatario: una por propietario y una por conductor.
     *
     * Cada persona tiene su propia fila porque leida y borrada viven en la
     * fila: con una sola compartida, el conductor que limpia su bandeja se la
     * limpiaria tambien al propietario. La bandeja filtra por destinatario
     * (ver visibleTo), asi que las copias no se ven duplicadas.
     *
     * La del conductor lleva su usuario en target_user_id -que es lo que la
     * hace suya y dirige su push- y el owner_id de su propio propietario, que
     * es el que el front usa para pedir su bandeja. Solo se crea si tiene
     * acceso a la app, y no se crea si su usuario es el de uno de los
     * propietarios avisados: el propietario que conduce recibe un solo aviso.
     */
    public void notifyOwnersAndDrivers(String eventType, String message, Collection<Long> ownerIds,
            Long referenceId, Collection<Long> driverIds, Integer actorUserId) {
        Set<Integer> notifiedUserIds = new HashSet<>();
        if (ownerIds != null) {
            for (Long ownerId : new LinkedHashSet<>(ownerIds)) {
                if (ownerId == null) {
                    continue;
                }
                createNotification(eventType, message, Constants.ROLE_ID_OWNER, null, ownerId, referenceId,
                        actorUserId);
                ownerRepository.findById(ownerId)
                        .map(Owner::getUser)
                        .map(Users::getId)
                        .ifPresent(notifiedUserIds::add);
            }
        }

        if (driverIds == null) {
            return;
        }
        for (Long driverId : new LinkedHashSet<>(driverIds)) {
            if (driverId == null) {
                continue;
            }
            driverRepository.findById(driverId)
                    // Sin propietario la fila caeria en la bandeja del administrador.
                    .filter(driver -> driver.getOwnerId() != null)
                    .ifPresent(driver -> pushRecipientResolver.resolveDriverUserId(driver)
                            .filter(notifiedUserIds::add)
                            .ifPresent(userId -> createNotification(eventType, message, Constants.ROLE_ID_DRIVER,
                                    userId, driver.getOwnerId(), referenceId, actorUserId)));
        }
    }

    /** Atajo para el caso comun de un propietario y, a lo sumo, un conductor. */
    public void notifyOwnerAndDriver(String eventType, String message, Long ownerId, Long referenceId,
            Long driverId) {
        notifyOwnersAndDrivers(eventType, message, ownerId == null ? List.of() : List.of(ownerId), referenceId,
                driverId == null ? List.of() : List.of(driverId), null);
    }

    /**
     * Bandeja de quien consulta. El front manda sus filtros -owner_id e
     * isDeleted- y aqui se les suma el destinatario, que el front no filtra.
     *
     * El administrador conserva lo que pide. Cualquier otro solo ve sus filas;
     * sin identidad no ve nada, porque no hay forma de saber cuales son suyas.
     */
    public Page<Notification> findWithFilterOptional(FilterRequest filterRequest, Integer callerUserId,
            boolean callerIsAdmin) {
        if (!callerIsAdmin && callerUserId == null) {
            return Page.empty(UtilsFilter.getPageable(filterRequest));
        }
        return findWithFilterOptional(filterRequest, callerIsAdmin ? null : visibleTo(callerUserId));
    }

    /**
     * Marca una notificacion como leida o borrada. Solo cambian esos dos
     * campos: antes se guardaba el objeto completo que mandaba el front, y una
     * copia de conductor que llegara sin targetUser pasaba a ser del
     * propietario, ademas de permitir reescribir el mensaje.
     */
    @Transactional
    public Notification updateState(Long id, Boolean isRead, Boolean isDeleted, Integer callerUserId,
            boolean callerIsAdmin) {
        Notification notification = notificationRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("Notification not found"));
        if (!callerIsAdmin && !isVisibleTo(notification, callerUserId)) {
            throw new NotificationAccessException("La notificación " + id + " no pertenece al usuario.");
        }
        if (isRead != null) {
            notification.setIsRead(isRead);
        }
        if (isDeleted != null) {
            notification.setIsDeleted(isDeleted);
        }
        return notificationRepository.save(notification);
    }

    /**
     * Regla de pertenencia: la fila dirigida al usuario, o la del propietario
     * -sin destinatario- cuando ese propietario es el usuario.
     */
    public static boolean isVisibleTo(Notification notification, Integer userId) {
        if (userId == null) {
            return false;
        }
        if (notification.getTargetUser() != null) {
            return userId.equals(notification.getTargetUser().getId());
        }
        Owner owner = notification.getOwner();
        return owner != null && owner.getUser() != null && userId.equals(owner.getUser().getId());
    }

    /** La misma regla que isVisibleTo, como condicion de la consulta. */
    private static Specification<Notification> visibleTo(Integer userId) {
        return (root, query, cb) -> {
            Join<Notification, Users> targetUser = root.join("targetUser", JoinType.LEFT);
            Join<Notification, Owner> owner = root.join("owner", JoinType.LEFT);
            Join<Owner, Users> ownerUser = owner.join("user", JoinType.LEFT);
            return cb.or(
                    cb.equal(targetUser.get("id"), userId),
                    cb.and(cb.isNull(targetUser.get("id")), cb.equal(ownerUser.get("id"), userId)));
        };
    }

    /** Alguien intento cambiar una notificacion que no es suya. */
    public static class NotificationAccessException extends RuntimeException {
        public NotificationAccessException(String message) {
            super(message);
        }
    }

    private Page<Notification> findWithFilterOptional(FilterRequest filterRequest,
            Specification<Notification> scope) {
        Pageable pageable = UtilsFilter.getPageable(filterRequest);
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        // Filter out deleted notifications by default if not explicitly searched
        boolean hasDeleteFilter = searchCriteriaList.stream()
                .anyMatch(c -> c.getKey().equals("isDeleted"));
        if (!hasDeleteFilter) {
            searchCriteriaList.add(new SearchCriteria("isDeleted", "=", false));
        }

        Specification<Notification> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }
        if (scope != null) {
            specification = specification == null ? scope : specification.and(scope);
        }

        Page<Notification> page;
        if (specification != null) {
            page = notificationRepository.findAll(specification, pageable);
        } else {
            page = notificationRepository.findAll(pageable);
        }

        return new PageImpl<>(page.getContent(), pageable, page.getTotalElements());
    }
}
