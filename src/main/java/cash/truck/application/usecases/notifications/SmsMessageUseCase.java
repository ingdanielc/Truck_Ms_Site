package cash.truck.application.usecases.notifications;

import cash.truck.application.strategies.SmsNotificationStrategy;
import cash.truck.application.utility.MapUtils;
import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.entities.notifications.Sms;
import cash.truck.domain.entities.notifications.Template;
import cash.truck.domain.enums.MediumEnum;
import cash.truck.domain.enums.MessageStatusEnum;
import cash.truck.domain.repositories.notifications.AuditRepository;
import cash.truck.domain.repositories.notifications.SmsRepository;
import cash.truck.domain.repositories.notifications.TemplateRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class SmsMessageUseCase {

    private static final Logger logger = LoggerFactory.getLogger(SmsMessageUseCase.class);
    private final SmsNotificationStrategy smsNotificationStrategy;
    private final TemplateRepository templateRepository;
    private final SmsRepository smsRepository;
    private final AuditRepository auditRepository;
    private final MapUtils mapUtils;

    SmsMessageUseCase(SmsNotificationStrategy smsNotificationStrategy, TemplateRepository templateRepository,
                      SmsRepository smsRepository,
                      AuditRepository auditRepository,
                      MapUtils mapUtils){
        this.smsNotificationStrategy = smsNotificationStrategy;
        this.templateRepository = templateRepository;
        this.smsRepository = smsRepository;
        this.auditRepository = auditRepository;
        this.mapUtils = mapUtils;
    }

    @Async
    public void sendSms(MessageRequest messageRequest, Audit audit) {
        try {
            Sms sms = setSmsEntity(messageRequest);
            audit.setMessageId(sms.getId());
            audit.setMessage("");
            if (messageRequest.getContent() == null || messageRequest.getContent().isEmpty()) {
                messageRequest.setContent(getTemplate(messageRequest, sms));
            }
            send(messageRequest, sms, audit);
        } catch (Exception e) {
            saveExceptionFailedSendMessage(audit, e);
        }
    }

    private void saveExceptionFailedSendMessage(Audit audit, Exception e) {
        audit.setErrorType(e.getMessage());
        audit.setStatus(MessageStatusEnum.FAILED.getName());
        auditRepository.save(audit);
        logger.error("Error processing SMS message: {}", e.getMessage(), e);
    }

    protected Sms setSmsEntity(MessageRequest messageRequest) {
        try {
            Sms sms = new Sms();
            sms.setMessageType(messageRequest.getMessageType() != null && !messageRequest.getMessageType().isEmpty() ?
                                        messageRequest.getMessageType() : null);
            sms.setStatus(MessageStatusEnum.PENDING.getName());
            sms.setPhoneNumber(messageRequest.getPhone());
            sms.setMessageContent(messageRequest.getContent() != null && !messageRequest.getContent().isEmpty() ?
                                        messageRequest.getContent() : null);
            sms.setMessageAttachment(messageRequest.getAttachmentUrl() != null && !messageRequest.getAttachmentUrl().isEmpty() ?
                                            messageRequest.getContent() : null);
            return smsRepository.save(sms);
        } catch (Exception e) {
            logger.error("Error saving Sms entity: {}", e.getMessage());
            throw new RuntimeException("Error saving Sms entity: " + e.getMessage());
        }
    }

    protected String getTemplate(MessageRequest messageRequest, Sms sms) {
        try {
            Template template = templateRepository.findByMediumAndMessageType(
                    MediumEnum.SMS.getName(), messageRequest.getMessageType()
            ).orElseThrow(() -> new RuntimeException("Template not found for the given parameters"));
            // AttachmentUrl Default
            if (messageRequest.getAttachmentUrl() == null || messageRequest.getAttachmentUrl().isEmpty()) {
                messageRequest.setAttachmentUrl(template.getAttachmentUrlDefault());
            }
            String content = mapUtils.mapTemplateValues(template, messageRequest.getData());
            sms.setTemplateId(template.getId());
            sms.setMessageContent(content);
            smsRepository.save(sms);
            return content;
        } catch (Exception e) {
            logger.error("Error retrieving template: {}", e.getMessage());
            throw new RuntimeException("Error retrieving template: " + e.getMessage(), e);
        }
    }

    protected void send(MessageRequest messageRequest, Sms sms, Audit audit) {
        try {
            smsNotificationStrategy.sendSms(messageRequest, sms, audit);
            audit.setStatus(MessageStatusEnum.SENT.getName());
        } catch (Exception e) {
            audit.setStatus(MessageStatusEnum.FAILED.getName());
            audit.setErrorType(e.getMessage());
            logger.error("Error sending sms: {}", e.getMessage(), e);
        } finally {
            auditRepository.save(audit);
        }
    }
}
