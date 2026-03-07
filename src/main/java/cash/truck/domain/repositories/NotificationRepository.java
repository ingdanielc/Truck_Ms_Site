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
}
