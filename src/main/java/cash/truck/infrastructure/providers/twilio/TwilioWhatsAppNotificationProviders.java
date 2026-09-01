package cash.truck.infrastructure.providers.twilio;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.rest.api.v2010.account.MessageCreator;
import com.twilio.type.PhoneNumber;
import cash.truck.application.strategies.WhatsAppNotificationStrategy;
import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.entities.notifications.WhatsApp;
import cash.truck.domain.enums.MessageStatusEnum;
import cash.truck.domain.repositories.notifications.AuditRepository;
import cash.truck.domain.repositories.notifications.WhatsAppRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

import java.net.URI;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.List;

@Slf4j
public class TwilioWhatsAppNotificationProviders implements WhatsAppNotificationStrategy {

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

        // Secuencial y bloqueante a proposito. whatsApp y audit son la misma
        // instancia para todos los destinatarios, asi que enviarlos en paralelo
        // hacia que dos hilos escribieran la misma fila; y sin esperar, el caso
        // de uso marcaba el envio como exitoso antes de que Twilio contestara.
        // El hilo de la peticion sigue libre porque quien llama corre en @Async.
        for (String recipient : messageRequest.getRecipients()) {
            sendMessage(recipient, messageRequest, whatsApp, audit);
        }
        log.info("All WhatsApp sending tasks are completed.");
    }

    private void sendMessage(String recipient, MessageRequest whatsappRequest, WhatsApp whatsApp, Audit audit) {
        try {
            Message message = create(recipient, whatsappRequest);

            log.info("Message sent to {} with SID: {}", recipient, message.getSid());
            saveMessageToDatabase(whatsappRequest, recipient, whatsApp, message.getSid(), audit,
                    MessageStatusEnum.SENT.getName(), null);
        } catch (Exception e) {
            // El motivo de Twilio se guarda tal cual: es lo unico que distingue
            // un numero mal formado de una plantilla sin aprobar (error 63016).
            log.error("Failed to send message to {}: {}", recipient, e.getMessage());
            saveMessageToDatabase(whatsappRequest, recipient, whatsApp, null, audit,
                    MessageStatusEnum.FAILED.getName(), e.getMessage());
        }
    }

    /**
     * Con una cuenta de pago WhatsApp solo acepta plantillas aprobadas en los
     * mensajes que inicia el negocio, y Twilio las envia por ContentSid en vez
     * de un cuerpo suelto. Se conserva la rama de texto libre porque sigue
     * siendo valida al responder dentro de la ventana de 24 horas.
     */
    private Message create(String recipient, MessageRequest whatsappRequest) {
        PhoneNumber to = new PhoneNumber("whatsapp:" + recipient);
        PhoneNumber from = new PhoneNumber("whatsapp:" + fromWhatsApp);

        if (whatsappRequest.getContentSid() == null || whatsappRequest.getContentSid().isBlank()) {
            return Message.creator(to, from, whatsappRequest.getContent())
                    .setMediaUrl(handleMediaUrls(whatsappRequest.getAttachmentUrl()))
                    .create(Twilio.getRestClient());
        }

        // El SDK no expone un creator sin cuerpo, asi que se entra por el de
        // media con la lista vacia: el request queda sin Body ni MediaUrl, que
        // es lo que corresponde cuando el contenido lo define la plantilla.
        MessageCreator creator = Message.creator(to, from, new ArrayList<URI>())
                .setContentSid(whatsappRequest.getContentSid());

        if (whatsappRequest.getContentVariables() != null && !whatsappRequest.getContentVariables().isBlank()) {
            creator.setContentVariables(whatsappRequest.getContentVariables());
        }
        return creator.create(Twilio.getRestClient());
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

    private void saveMessageToDatabase(MessageRequest whatsappRequest, String recipient, WhatsApp whatsApp,
                                       String providerMessageId, Audit audit, String status, String error) {
        whatsApp.setPhoneNumber(recipient);
        whatsApp.setMessageContent(whatsappRequest.getContent());
        // Antes guardaba "send"/"failed" en crudo, fuera del vocabulario de
        // MessageStatusEnum con el que nace la fila y que consulta el resto.
        whatsApp.setStatus(status);
        whatsApp.setMessageProvideId(providerMessageId);
        whatsappRepository.save(whatsApp);

        audit.setStatus(status);
        audit.setMessage(whatsappRequest.getContent());
        audit.setErrorType(error);
        auditRepository.save(audit);
    }
}
