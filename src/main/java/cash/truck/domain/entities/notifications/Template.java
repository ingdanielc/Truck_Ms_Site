package cash.truck.domain.entities.notifications;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "template", uniqueConstraints = {@UniqueConstraint(columnNames = {"medium", "message_type"})})
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Template {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "medium", nullable = false)
    private String medium;

    @Column(name = "message_type", nullable = false)
    private String messageType;

    @Lob
    @Column(name = "attachment_url_default", columnDefinition = "NVARCHAR(MAX)")
    private String attachmentUrlDefault;

    @Lob
    @Column(name = "template_content", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String templateContent;

    @Lob
    @Column(name = "template_subject", nullable = false, columnDefinition = "NVARCHAR(MAX)")
    private String templateSubject;
}

