package cash.truck.domain.entities.notifications;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "whatsapp")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class WhatsApp {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", updatable = false, nullable = false)
    private Long id;

    @Column(name = "message_provide_id")
    private String messageProvideId;

    @Column(name = "phone_number", nullable = false)
    private String phoneNumber;

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

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Column(name = "timestamp", nullable = false, updatable = false)
    private LocalDateTime timestamp;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    @Column(name = "updated_at", insertable = false, updatable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        this.timestamp = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}
