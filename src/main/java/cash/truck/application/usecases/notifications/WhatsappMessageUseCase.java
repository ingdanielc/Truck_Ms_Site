package cash.truck.application.usecases.notifications;

import cash.truck.application.strategies.WhatsAppNotificationStrategy;
import cash.truck.application.utility.MapUtils;
import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.entities.notifications.Template;
import cash.truck.domain.entities.notifications.WhatsApp;
import cash.truck.domain.enums.MediumEnum;
import cash.truck.domain.enums.MessageStatusEnum;
import cash.truck.domain.repositories.notifications.AuditRepository;
import cash.truck.domain.repositories.notifications.TemplateRepository;
import cash.truck.domain.repositories.notifications.WhatsAppRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class WhatsappMessageUseCase {

    private static final Logger logger = LoggerFactory.getLogger(WhatsappMessageUseCase.class);
    private final WhatsAppNotificationStrategy whatsAppNotificationStrategy;
    private final TemplateRepository templateRepository;
    private final WhatsAppRepository whatsAppRepository;
    private final AuditRepository auditRepository;
    private final MapUtils mapUtils;

    WhatsappMessageUseCase(WhatsAppNotificationStrategy whatsAppNotificationStrategy,
                           TemplateRepository templateRepository,
                           WhatsAppRepository whatsAppRepository,
                           AuditRepository auditRepository,
                           MapUtils mapUtils){
        this.whatsAppNotificationStrategy = whatsAppNotificationStrategy;
        this.templateRepository = templateRepository;
        this.whatsAppRepository = whatsAppRepository;
        this.auditRepository = auditRepository;
        this.mapUtils = mapUtils;
    }

    @Async
    public void sendWhatsApp(MessageRequest messageRequest, Audit audit) {
        try {
            WhatsApp whatsApp = setWhatsAppEntity(messageRequest);
            audit.setMessageId(whatsApp.getId());
            audit.setMessageType(MediumEnum.WHATSAPP.getName());
            audit.setMessage("");
            if (messageRequest.getContent() == null || messageRequest.getContent().isEmpty()) {
                messageRequest.setContent(getTemplate(messageRequest, whatsApp));
            }
            send(messageRequest, whatsApp, audit);
        } catch (Exception e) {
            audit.setErrorType(e.getMessage());
            audit.setStatus(MessageStatusEnum.FAILED.getName());
            auditRepository.save(audit);
            logger.error("Error processing WhatsApp message: {}", e.getMessage(), e);
        }
    }

    protected WhatsApp setWhatsAppEntity(MessageRequest messageRequest) {
        try {
            WhatsApp whatsApp = new WhatsApp();
            whatsApp.setStatus(MessageStatusEnum.PENDING.getName());

            if (messageRequest.getPhone() == null || messageRequest.getPhone().isEmpty()) {
                throw new IllegalArgumentException("Phone number is required for WhatsApp messages.");
            }
            whatsApp.setPhoneNumber(messageRequest.getPhone());

            if (messageRequest.getMessageType() != null && !messageRequest.getMessageType().isEmpty()) {
                whatsApp.setMessageType(messageRequest.getMessageType());
            }

            if (messageRequest.getContent() != null && !messageRequest.getContent().isEmpty()) {
                whatsApp.setMessageContent(messageRequest.getContent());
            }

            if (messageRequest.getAttachmentUrl() != null  && !messageRequest.getAttachmentUrl().isEmpty()) {
                whatsApp.setMessageAttachment(messageRequest.getAttachmentUrl());
            }

            return whatsAppRepository.save(whatsApp);
        } catch (Exception e) {
            logger.error("Error saving WhatsApp entity: {}", e.getMessage());
            throw new RuntimeException("Error saving WhatsApp entity: " + e.getMessage());
        }
    }

    protected String getTemplate(MessageRequest messageRequest, WhatsApp whatsApp) {
        try {
            Template template = templateRepository.findByMediumAndMessageType(
                    MediumEnum.WHATSAPP.getName(), messageRequest.getMessageType()
            ).orElseThrow(() -> new RuntimeException("Template not found for the given parameters"));
            // AttachmentUrl Default
            if (messageRequest.getAttachmentUrl() == null || messageRequest.getAttachmentUrl().isEmpty()) {
                messageRequest.setAttachmentUrl(template.getAttachmentUrlDefault());
            }
            String content = mapUtils.mapTemplateValues(template, messageRequest.getData());

            // La plantilla aprobada en Twilio, cuando la hay. El contenido local
            // se sigue calculando: es lo que queda en la auditoria como texto
            // realmente enviado, y es lo que usan SMS y correo.
            messageRequest.setContentSid(template.getProviderTemplateId());
            messageRequest.setContentVariables(
                    mapUtils.mapContentVariables(template.getProviderVariables(), messageRequest.getData()));

            if (template.getProviderTemplateId() == null || template.getProviderTemplateId().isBlank()) {
                // Sin ContentSid el mensaje sale como texto libre y WhatsApp lo
                // rechaza (error 63016) salvo que el destinatario haya escrito en
                // las ultimas 24 horas. Se avisa aqui porque es el unico punto
                // donde se sabe que plantilla falta por registrar.
                logger.warn("La plantilla {} no tiene ContentSid aprobado: el mensaje sale como texto libre "
                        + "y WhatsApp lo rechaza fuera de la ventana de 24 horas. "
                        + "Registrelo en provider_template_id, como hace scripts/info.sql",
                        messageRequest.getMessageType());
            }

            whatsApp.setTemplateId(template.getId());
            whatsApp.setMessageContent(content);
            whatsAppRepository.save(whatsApp);
            return content;
        } catch (Exception e) {
            logger.error("Error retrieving template: {}", e.getMessage());
            throw new RuntimeException("Error retrieving template: " + e.getMessage(), e);
        }
    }

    protected void send(MessageRequest whatsappRequest, WhatsApp whatsApp, Audit audit) {
        try {
            whatsAppNotificationStrategy.sendWhatsApp(whatsappRequest, whatsApp, audit);
            // El proveedor ya dejo el resultado real de Twilio. Solo se completa
            // el estado cuando no alcanzo a escribirlo, para no convertir en
            // "Sent" un envio que en realidad fallo.
            if (audit.getStatus() == null || audit.getStatus().isBlank()) {
                audit.setStatus(MessageStatusEnum.SENT.getName());
            }
        } catch (Exception e) {
            audit.setStatus(MessageStatusEnum.FAILED.getName());
            audit.setErrorType(e.getMessage());
            logger.error("Error sending WhatsApp message: {}", e.getMessage(), e);
        } finally {
            auditRepository.save(audit);
        }
    }
}
