package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.dtos.NotificationCreatedEvent;
import cash.truck.domain.entities.Notification;
import cash.truck.domain.repositories.NotificationRepository;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.RolesRepository;
import cash.truck.domain.repositories.UsersRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;

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
                ownerId, referenceId, targetUserId));

        return saved;
    }

    public Page<Notification> findWithFilterOptional(FilterRequest filterRequest) {
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

        Page<Notification> page;
        if (specification != null) {
            page = notificationRepository.findAll(specification, pageable);
        } else {
            page = notificationRepository.findAll(pageable);
        }

        return new PageImpl<>(page.getContent(), pageable, page.getTotalElements());
    }
}
