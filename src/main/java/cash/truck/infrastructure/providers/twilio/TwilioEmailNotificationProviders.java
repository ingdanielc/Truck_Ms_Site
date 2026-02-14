package cash.truck.infrastructure.providers.twilio;

import com.sendgrid.Method;
import com.sendgrid.Request;
import com.sendgrid.Response;
import com.sendgrid.SendGrid;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Content;
import cash.truck.application.strategies.EmailNotificationStrategy;
import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.entities.notifications.Email;
import cash.truck.domain.enums.MessageStatusEnum;
import cash.truck.domain.repositories.notifications.AuditRepository;
import cash.truck.domain.repositories.notifications.EmailRepository;
import org.apache.http.HttpStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CompletableFuture;

public class TwilioEmailNotificationProviders implements EmailNotificationStrategy {

    private static final Logger logger = LoggerFactory.getLogger(TwilioEmailNotificationProviders.class);

    private static final String PROVIDER_SENDGRID = "SENDGRID";
    @Value("${sendgrid.api.key}")
    private String sendGridApiKey;

    @Value("${sendgrid.email.from}")
    private String fromEmail;

    @Autowired
    private EmailRepository emailRepository;

    @Autowired
    private AuditRepository auditRepository;

    @Override
    public void sendEmail(MessageRequest messageRequest, Email email, Audit audit) {
        List<CompletableFuture<Void>> futures = messageRequest.getRecipients().stream()
                .map(recipient -> CompletableFuture.runAsync(() -> sendMessage(recipient, messageRequest, email, audit)))
                .toList();
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
                .thenRun(() -> logger.info("All Email sending tasks are completed."));
    }

    private void sendMessage(String recipient, MessageRequest emailRequest, Email email, Audit audit) {
        try {
            com.sendgrid.helpers.mail.objects.Email emailFrom = new com.sendgrid.helpers.mail.objects.Email(fromEmail);
            String subject = emailRequest.getSubject();
            com.sendgrid.helpers.mail.objects.Email emailTo = new com.sendgrid.helpers.mail.objects.Email(recipient);
            Content content = new Content("text/html", emailRequest.getContent());
            Mail mail = new Mail(emailFrom, subject, emailTo, content);
            SendGrid sendGrid = new SendGrid(sendGridApiKey);
            Response response = sendGridRequest(mail, sendGrid);
            saveMessageToDatabase(emailRequest, recipient, email, response.getStatusCode(),response.getBody() , audit, MessageStatusEnum.SENT.getName());
        } catch (Exception e) {
            logger.error("Failed to send message to {}: {}", recipient, e.getMessage());
            saveMessageToDatabase(emailRequest, recipient, email, null, e.getMessage() , audit, MessageStatusEnum.FAILED.getName());
        }
    }

    private static Response sendGridRequest(Mail mail, SendGrid sendGrid) throws IOException {
        Request request = new Request();
        request.setMethod(Method.POST);
        request.setEndpoint("mail/send");
        request.setBody(mail.build());
        Response response = sendGrid.api(request);
        String responseBody = response.getBody();
        logger.info("Response from SendGrid Email API: {}", responseBody);
        if (responseBody != null && !responseBody.isEmpty() && response.getStatusCode() == 202) {
                logger.info("Success Send Email SendGrid API");
        }
        return response;
    }
    

    private void saveMessageToDatabase(MessageRequest emailRequest, String recipient, Email email, Integer providerMessageStatus, String providerMessage, Audit audit, String auditStatus) {
        email.setMessageType(PROVIDER_SENDGRID);
        email.setStatus(providerMessageStatus != null && providerMessageStatus == HttpStatus.SC_ACCEPTED ? MessageStatusEnum.SENT.getName() : MessageStatusEnum.FAILED.getName());
        email.setMessageProvideStatus(providerMessageStatus != null ? String.valueOf(providerMessageStatus) : String.valueOf(HttpStatus.SC_INTERNAL_SERVER_ERROR));
        email.setMessageProvider(providerMessage);
        email.setRecipient(recipient);
        emailRepository.save(email);

        audit.setStatus(auditStatus);
        audit.setMessage(emailRequest.getContent());
        audit.setErrorType(providerMessageStatus != null ? null : "Failed to send message");
        auditRepository.save(audit);
    }

}
