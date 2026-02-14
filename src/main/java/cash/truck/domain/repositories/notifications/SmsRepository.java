package cash.truck.domain.repositories.notifications;

import cash.truck.domain.entities.notifications.Sms;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SmsRepository extends JpaRepository<Sms, Long> {
}