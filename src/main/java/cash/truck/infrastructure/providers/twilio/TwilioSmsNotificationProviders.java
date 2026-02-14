package cash.truck.infrastructure.providers.twilio;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import cash.truck.application.strategies.SmsNotificationStrategy;
import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.entities.notifications.Sms;
import cash.truck.domain.enums.MessageStatusEnum;
import cash.truck.domain.repositories.notifications.AuditRepository;
import cash.truck.domain.repositories.notifications.SmsRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.CompletableFuture;

public class TwilioSmsNotificationProviders implements SmsNotificationStrategy {

    private static final Logger logger = LoggerFactory.getLogger(TwilioSmsNotificationProviders.class);

    @Value("${twilio.account.sid}")
    private String accountSid;

    @Value("${twilio.auth.token}")
    private String authToken;

    @Value("${twilio.sms.from}")
    private String fromSms;

    @Autowired
    private SmsRepository smsRepository;

    @Autowired
    private AuditRepository auditRepository;

    @Override
    public void sendSms(MessageRequest messageRequest, Sms sms, Audit audit) {
        Twilio.init(accountSid, authToken);
        List<CompletableFuture<Void>> futures = messageRequest.getRecipients().stream()
                .map(recipient -> CompletableFuture.runAsync(() -> sendMessage(recipient, messageRequest, sms, audit)))
                .toList();
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
                .thenRun(() -> logger.info("All SMS sending tasks are completed."));
    }

    private void sendMessage(String recipient, MessageRequest smsRequest, Sms sms, Audit audit) {
        try {
            Message message = Message.creator(
                            new PhoneNumber(recipient),
                            new PhoneNumber(fromSms),
                            smsRequest.getContent()
                    )
                    .setMediaUrl(handleMediaUrls(smsRequest.getAttachmentUrl()))
                    .create(Twilio.getRestClient());

            logger.info("Message sent to {} with SID: {}", recipient, message.getSid());
            saveMessageToDatabase(smsRequest, recipient, "send", sms, message.getSid(), audit, MessageStatusEnum.SENT.getName());
        } catch (Exception e) {
            logger.error("Failed to send message to {}: {}", recipient, e.getMessage());
            saveMessageToDatabase(smsRequest, recipient, "failed", sms, null, audit, MessageStatusEnum.FAILED.getName());
        }
    }

    private List<URI> handleMediaUrls(String mediaUrl) {
        if (mediaUrl != null && !mediaUrl.isEmpty()) {
            List<URI> mediaUrls = new ArrayList<>();
            try {
                mediaUrls.add(new URI(mediaUrl));
            } catch (URISyntaxException e) {
                logger.error("Invalid media URL: {}", mediaUrl, e);
            }
            return mediaUrls;
        }
        return Collections.emptyList();
    }

    private void saveMessageToDatabase(MessageRequest smsRequest, String recipient, String status, Sms sms, String providerMessageId, Audit audit, String auditStatus) {
        sms.setPhoneNumber(recipient);
        sms.setMessageContent(smsRequest.getContent());
        sms.setStatus(status);
        sms.setMessageProvideId(providerMessageId);
        smsRepository.save(sms);
        
        audit.setStatus(auditStatus);
        audit.setMessage(smsRequest.getContent());
        audit.setErrorType(providerMessageId != null ? null : "Failed to send message");
        auditRepository.save(audit);
    }
}
