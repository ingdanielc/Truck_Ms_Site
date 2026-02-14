package cash.truck.domain.repositories.notifications;

import cash.truck.domain.entities.notifications.WhatsApp;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WhatsAppRepository extends JpaRepository<WhatsApp, Long> {
    WhatsApp findByMessageProvideId(String messageProvideId);
    WhatsApp findTopByPhoneNumberOrderByTimestampDesc(String phoneNumber);
}
