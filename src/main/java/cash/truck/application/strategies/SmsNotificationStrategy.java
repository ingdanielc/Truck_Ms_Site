package cash.truck.application.strategies;

import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.entities.notifications.Sms;

public interface SmsNotificationStrategy {
    void sendSms(MessageRequest messageRequest, Sms whatsAppEntity, Audit audit);
}
