package cash.truck.infrastructure.providers.gmail;

import cash.truck.application.strategies.EmailNotificationStrategy;
import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.entities.notifications.Email;
import cash.truck.domain.enums.MessageStatusEnum;
import cash.truck.domain.repositories.notifications.AuditRepository;
import cash.truck.domain.repositories.notifications.EmailRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

public class GmailEmailNotificationProviders implements EmailNotificationStrategy {

    private static final Logger logger = LoggerFactory.getLogger(GmailEmailNotificationProviders.class);

    @Value("${gmail.host}")
    private String host;

    @Value("${gmail.port}")
    private int port;

    @Value("${gmail.username}")
    private String username;

    @Value("${gmail.password}")
    private String password;

    @Value("${gmail.from}")
    private String from;

    @Autowired
    private EmailRepository emailRepository;

    @Autowired
    private AuditRepository auditRepository;

    @Override
    public void sendEmail(MessageRequest messageRequest, Email email, Audit audit) {
        // Propiedades del servidor SMTP de Gmail
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", String.valueOf(port));

        // Autenticación
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            // Construcción del mensaje
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(String.join(",", messageRequest.getRecipients())));
            message.setSubject(messageRequest.getSubject() != null ? messageRequest.getSubject() : "Default Subject");
            message.setContent(messageRequest.getContent(), "text/html");

            // Envío del mensaje
            Transport.send(message);

            // Actualización de las entidades Email y Audit
            email.setStatus(MessageStatusEnum.SENT.getName());
            emailRepository.save(email);

            audit.setStatus(MessageStatusEnum.SENT.getName());
            audit.setMessage("Email successfully sent to: " + String.join(", ", messageRequest.getRecipients()));
            auditRepository.save(audit);

            logger.info("Email successfully sent to: {}", String.join(", ", messageRequest.getRecipients()));
        } catch (Exception e) {
            // Manejo de errores
            email.setStatus(MessageStatusEnum.FAILED.getName());
            emailRepository.save(email);

            audit.setStatus(MessageStatusEnum.FAILED.getName());
            audit.setErrorType(e.getMessage());
            auditRepository.save(audit);

            logger.error("Error sending email to {}: {}", String.join(", ", messageRequest.getRecipients()), e.getMessage(), e);
        }
    }
}
