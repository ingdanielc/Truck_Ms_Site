package cash.truck.infrastructure.providers.twilio;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import cash.truck.application.strategies.WhatsAppNotificationStrategy;
import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.entities.notifications.WhatsApp;
import cash.truck.domain.enums.MessageStatusEnum;
import cash.truck.domain.repositories.notifications.AuditRepository;
import cash.truck.domain.repositories.notifications.WhatsAppRepository;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;

@Slf4j
public class TwilioWhatsAppNotificationProviders implements WhatsAppNotificationStrategy {

    private static final Logger logger = LoggerFactory.getLogger(TwilioWhatsAppNotificationProviders.class);

    @Value("${twilio.account.sid}")
    private String accountSid;

    @Value("${twilio.auth.token}")
    private String authToken;

    @Value("${twilio.whatsapp.from}")
    private String fromWhatsApp;

    @Autowired
    private WhatsAppRepository whatsappRepository;

    @Autowired
    private AuditRepository auditRepository;

    @Override
    public void sendWhatsApp(MessageRequest messageRequest, WhatsApp whatsApp, Audit audit) {
        Twilio.init(accountSid, authToken);
        List<CompletableFuture<Void>> futures = messageRequest.getRecipients().stream()
                .map(recipient -> CompletableFuture.runAsync(() -> sendMessage(recipient, messageRequest, whatsApp, audit)))
                .toList();
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
                .thenRun(() -> log.info("All WhatsApp sending tasks are completed."));
    }

    private void sendMessage(String recipient, MessageRequest whatsappRequest, WhatsApp whatsApp, Audit audit) {
        try {
            Message message = Message.creator(
                            new PhoneNumber("whatsapp:" + recipient),
                            new PhoneNumber("whatsapp:" + fromWhatsApp),
                            whatsappRequest.getContent()
                    )
                    .setMediaUrl(handleMediaUrls(whatsappRequest.getAttachmentUrl()))
                    .create(Twilio.getRestClient());

            log.info("Message sent to {} with SID: {}", recipient, message.getSid());
            saveMessageToDatabase(whatsappRequest, recipient, "send", whatsApp, message.getSid(), audit, MessageStatusEnum.SENT.getName());
        } catch (Exception e) {
            log.error("Failed to send message to {}: {}", recipient, e.getMessage());
            saveMessageToDatabase(whatsappRequest, recipient, "failed", whatsApp, null, audit, MessageStatusEnum.FAILED.getName());
        }
    }

    private List<URI> handleMediaUrls(String mediaUrl) {
        if (mediaUrl != null && !mediaUrl.isEmpty()) {
            List<URI> mediaUrls = new ArrayList<>();
            try {
                mediaUrls.add(new URI(mediaUrl));
            } catch (URISyntaxException e) {
                log.error("Invalid media URL: {}", mediaUrl, e);
            }
            return mediaUrls;
        }
        return null;
    }

    private void saveMessageToDatabase(MessageRequest whatsappRequest, String recipient, String status, WhatsApp whatsApp, String providerMessageId, Audit audit, String auditStatus) {
        whatsApp.setPhoneNumber(recipient);
        whatsApp.setMessageContent(whatsappRequest.getContent());
        whatsApp.setStatus(status);
        whatsApp.setMessageProvideId(providerMessageId);
        whatsappRepository.save(whatsApp);

        audit.setStatus(auditStatus);
        audit.setMessage(whatsappRequest.getContent());
        audit.setErrorType(providerMessageId != null ? null : "Failed to send message");
        auditRepository.save(audit);
    }
}
