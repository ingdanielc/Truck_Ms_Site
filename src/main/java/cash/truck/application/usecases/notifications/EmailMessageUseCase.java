package cash.truck.application.usecases.notifications;

import cash.truck.application.strategies.EmailNotificationStrategy;
import cash.truck.application.utility.MapUtils;
import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.entities.notifications.Email;
import cash.truck.domain.entities.notifications.Template;
import cash.truck.domain.enums.MediumEnum;
import cash.truck.domain.enums.MessageStatusEnum;
import cash.truck.domain.repositories.notifications.AuditRepository;
import cash.truck.domain.repositories.notifications.EmailRepository;
import cash.truck.domain.repositories.notifications.TemplateRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class EmailMessageUseCase {

    private static final Logger logger = LoggerFactory.getLogger(EmailMessageUseCase.class);
    private final EmailNotificationStrategy emailNotificationStrategy;
    private final TemplateRepository templateRepository;
    private final EmailRepository emailRepository;
    private final AuditRepository auditRepository;
    private final MapUtils mapUtils;

    @Autowired
    EmailMessageUseCase(EmailNotificationStrategy emailNotificationStrategy, TemplateRepository templateRepository,
                        EmailRepository emailRepository,
                        AuditRepository auditRepository,
                        MapUtils mapUtils){
        this.emailNotificationStrategy = emailNotificationStrategy;
        this.templateRepository = templateRepository;
        this.emailRepository = emailRepository;
        this.auditRepository = auditRepository;
        this.mapUtils = mapUtils;
    }

    @Async
    public void sendEmail(MessageRequest messageRequest, Audit audit) {
        try {
            Template template = templateRepository.findByMediumAndMessageType(
                    MediumEnum.EMAIL.getName(), messageRequest.getMessageType()
            ).orElseThrow(() -> new RuntimeException("Template not found for the given parameters")); 
            Email email = setEmailEntity(messageRequest, template);
            audit.setMessageId(email.getId());
            audit.setMessage("");
            if (messageRequest.getContent() == null || messageRequest.getContent().isEmpty()) {
                messageRequest.setContent(getTemplate(messageRequest, email, template));
            }
            send(messageRequest, email, audit);
        } catch (Exception e) {
            audit.setErrorType(e.getMessage());
            audit.setStatus(MessageStatusEnum.FAILED.getName());
            auditRepository.save(audit);
            logger.error("Error processing Email message: {}", e.getMessage(), e);
        }
    }

    protected Email setEmailEntity(MessageRequest messageRequest, Template template) {
        try {
            Email email = new Email();
            email.setStatus(MessageStatusEnum.PENDING.getName());

            if (template.getTemplateSubject() == null || template.getTemplateSubject().isEmpty()) {
                throw new IllegalArgumentException("Subject is required for sending emails.");
            }
            email.setSubject(template.getTemplateSubject());

            if (messageRequest.getRecipients() == null || messageRequest.getRecipients().isEmpty()) {
                throw new IllegalArgumentException("Recipient or Recipients is required for sending emails.");
            }
            email.setRecipient(messageRequest.getRecipients().toString());
            if (messageRequest.getMessageType() != null && !messageRequest.getMessageType().isEmpty()) {
                email.setMessageType(messageRequest.getMessageType());
            }

            if (messageRequest.getContent() != null && !messageRequest.getContent().isEmpty()) {
                email.setMessageContent(messageRequest.getContent());
            }

            if (messageRequest.getAttachmentUrl() != null) {
                email.setMessageAttachment(messageRequest.getAttachmentUrl());
            }

            return emailRepository.save(email);
        } catch (Exception e) {
            logger.error("Error saving Email entity: {}", e.getMessage());
            throw new RuntimeException("Error saving Email entity: " + e.getMessage());
        }
    }

    protected String getTemplate(MessageRequest messageRequest, Email email, Template template) {
        try {
            // AttachmentUrl Default
            if (messageRequest.getAttachmentUrl() == null || messageRequest.getAttachmentUrl().isEmpty()) {
                messageRequest.setAttachmentUrl(template.getAttachmentUrlDefault());
            }
            String content = mapUtils.mapTemplateValues(template, messageRequest.getData());
            messageRequest.setSubject(template.getTemplateSubject()); //Subject of template registered
            email.setTemplateId(template.getId());
            email.setMessageContent(content);
            emailRepository.save(email);
            return content;
        } catch (Exception e) {
            logger.error("Error retrieving template: {}", e.getMessage());
            throw new RuntimeException("Error retrieving template: " + e.getMessage(), e);
        }
    }

    protected void send(MessageRequest messageRequest, Email email, Audit audit) {
        try {
            emailNotificationStrategy.sendEmail(messageRequest, email, audit);
            audit.setStatus(MessageStatusEnum.SENT.getName());
        } catch (Exception e) {
            audit.setStatus(MessageStatusEnum.FAILED.getName());
            audit.setErrorType(e.getMessage());
            logger.error("Error sending email: {}", e.getMessage(), e);
        } finally {
            auditRepository.save(audit);
        }
    }
}
