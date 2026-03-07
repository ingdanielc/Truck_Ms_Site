package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.Notification;
import cash.truck.domain.repositories.NotificationRepository;
import cash.truck.domain.repositories.RolesRepository;
import cash.truck.domain.repositories.UsersRepository;
import org.springframework.beans.factory.annotation.Autowired;
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

    public List<Notification> getAllNotifications() {
        return notificationRepository.findAll();
    }

    public Notification saveNotification(Notification notification) {
        return notificationRepository.save(notification);
    }

    public void createNotification(String eventType, String message, Integer targetRoleId, Integer targetUserId,
            Long referenceId) {
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

        notificationRepository.save(notification);
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
