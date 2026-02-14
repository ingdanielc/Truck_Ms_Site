package cash.truck.domain.entities.notifications;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "email")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Email {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "subject")
    private String subject;

    @Column(name = "message_provider_status")
    private String messageProvideStatus;

    @Column(name = "message_type")
    private String messageType;

    @Column(name = "template_id")
    private Long templateId;

    @Lob
    @Column(name = "message_content", columnDefinition = "NVARCHAR(MAX)")
    private String messageContent;

    @Column(name = "message_attachment")
    private String messageAttachment;

    @Column(name = "status", nullable = false)
    private String status;

    @Column(name = "timestamp", nullable = false, updatable = false)
    private LocalDateTime timestamp = LocalDateTime.now();

    @Column(name = "recipient", nullable = false)
    private String recipient;

    @Lob
    @Column(name = "message_provider", columnDefinition = "NVARCHAR(MAX)")
    private String messageProvider;
}
