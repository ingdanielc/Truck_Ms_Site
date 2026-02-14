package cash.truck.domain.repositories.notifications;

import cash.truck.domain.entities.notifications.Template;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TemplateRepository extends JpaRepository<Template, Long> {
    Optional<Template> findByMediumAndMessageType(String medium, String messageType);
}
