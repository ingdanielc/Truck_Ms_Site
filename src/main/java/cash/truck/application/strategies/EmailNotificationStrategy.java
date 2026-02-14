package cash.truck.application.strategies;

import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.entities.notifications.Email;

public interface EmailNotificationStrategy {
    void sendEmail(MessageRequest messageRequest, Email email, Audit audit);
}
