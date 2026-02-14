package cash.truck.domain.repositories.notifications;

import cash.truck.domain.entities.notifications.Email;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface EmailRepository extends JpaRepository<Email, Long> {
}
