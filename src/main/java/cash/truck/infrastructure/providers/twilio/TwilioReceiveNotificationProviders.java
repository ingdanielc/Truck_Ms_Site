package cash.truck.infrastructure.providers.twilio;

import cash.truck.domain.dtos.twilio.MessageResponseTwilio;
import cash.truck.domain.dtos.twilio.StatusResponseTwilio;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.entities.notifications.WhatsApp;
import cash.truck.domain.enums.MediumEnum;
import cash.truck.domain.repositories.notifications.AuditRepository;
import cash.truck.domain.repositories.notifications.WhatsAppRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

@Service
public class TwilioReceiveNotificationProviders {

    private static final Logger logger = LoggerFactory.getLogger(TwilioReceiveNotificationProviders.class);

    @Autowired
    private WhatsAppRepository whatsappRepository;

    @Autowired
    private AuditRepository auditRepository;

    public void receiveMessage(String messageResponse) {
        Audit audit = new Audit();
        try {
            MessageResponseTwilio messageResponseTwilio = mapToMessageResponse(messageResponse);

            audit.setMessage(messageResponse);
            audit.setStatus(messageResponseTwilio.getSmsStatus());
            audit.setErrorType(null);
            auditRepository.save(audit);

            WhatsApp whatsapp = whatsappRepository
                    .findTopByPhoneNumberOrderByTimestampDesc("+"+messageResponseTwilio.getWaId());

            if (whatsapp != null) {
                audit.setMessageId(whatsapp.getId());
                audit.setMessageType(MediumEnum.WHATSAPP.getName());
                auditRepository.save(audit);

                whatsapp.setStatus(messageResponseTwilio.getSmsStatus());
                whatsappRepository.save(whatsapp);
                logger.info("Message status updated successfully from Twilio.");
            } else {
                logger.error("WhatsApp record not found for WaId: " + messageResponseTwilio.getWaId());
                audit.setErrorType("WhatsApp record not found for WaId: " + messageResponseTwilio.getWaId());
                auditRepository.save(audit);
            }
        } catch (Exception e) {
            logger.error("Error processing message response: " + messageResponse, e);
            audit.setErrorType(e.getMessage());
            audit.setMessage("Error processing message response");
            auditRepository.save(audit);
        }
    }

    public void receiveStatus(String statusResponse) {
        Audit audit = new Audit();
        try {

            StatusResponseTwilio statusResponseTwilio = mapToStatusResponse(statusResponse);

            audit.setMessage(statusResponse);
            audit.setStatus(statusResponseTwilio.getSmsStatus());
            audit.setErrorType(null);
            auditRepository.save(audit);

            WhatsApp whatsapp = whatsappRepository.findByMessageProvideId(statusResponseTwilio.getMessageSid());

            if (whatsapp != null) {

                audit.setMessageId(whatsapp.getId());
                audit.setMessageType(MediumEnum.WHATSAPP.getName());
                auditRepository.save(audit);

                whatsapp.setStatus(statusResponseTwilio.getSmsStatus());
                whatsappRepository.save(whatsapp);
                logger.info("Message status updated successfully from Twilio.");
            } else {
                logger.error("WhatsApp record not found for messageSid: " + statusResponseTwilio.getMessageSid());
                audit.setErrorType("WhatsApp record not found for messageSid: " + statusResponseTwilio.getMessageSid());
                auditRepository.save(audit);
            }
        } catch (Exception e) {
            logger.error("Error processing status response: " + statusResponse, e);
            audit.setErrorType(e.getMessage());
            audit.setStatus("Error processing status response");
            audit.setMessage(statusResponse);
            auditRepository.save(audit);
        }
    }

    public static StatusResponseTwilio mapToStatusResponse(String queryString) {
        Map<String, String> parameters = new HashMap<>();
        String[] pairs = queryString.split("&");

        for (String pair : pairs) {
            String[] keyValue = pair.split("=");
            String key = keyValue[0];
            String value = keyValue.length > 1 ? URLDecoder.decode(keyValue[1], StandardCharsets.UTF_8) : "";
            parameters.put(key, value);
        }

        return new StatusResponseTwilio(
                parameters.get("ChannelPrefix"),
                parameters.get("ApiVersion"),
                parameters.get("MessageStatus"),
                parameters.get("SmsSid"),
                parameters.get("SmsStatus"),
                parameters.get("ChannelInstallSid"),
                parameters.get("To"),
                parameters.get("From"),
                parameters.get("MessageSid"),
                parameters.get("AccountSid"),
                parameters.get("ChannelToAddress")
        );
    }

    public static MessageResponseTwilio mapToMessageResponse(String queryString) {
        Map<String, String> parameters = new HashMap<>();
        String[] pairs = queryString.split("&");

        for (String pair : pairs) {
            String[] keyValue = pair.split("=");
            String key = keyValue[0];
            String value = keyValue.length > 1 ? URLDecoder.decode(keyValue[1], StandardCharsets.UTF_8) : "";
            parameters.put(key, value);
        }

        return new MessageResponseTwilio(
                parameters.get("SmsMessageSid"),
                parameters.get("NumMedia"),
                parameters.get("ProfileName"),
                parameters.get("MessageType"),
                parameters.get("SmsSid"),
                parameters.get("WaId"),
                parameters.get("SmsStatus"),
                parameters.get("Body"),
                parameters.get("To"),
                parameters.get("NumSegments"),
                parameters.get("ReferralNumMedia"),
                parameters.get("MessageSid"),
                parameters.get("AccountSid"),
                parameters.get("From"),
                parameters.get("ApiVersion")
        );
    }

}
