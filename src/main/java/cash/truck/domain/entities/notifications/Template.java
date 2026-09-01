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

    /**
     * ContentSid (HX...) de la plantilla aprobada en Twilio. WhatsApp rechaza el
     * texto libre en mensajes que inicia el negocio, asi que sin esto la
     * notificacion no sale. Nulo significa enviar texto libre, que sigue siendo
     * valido dentro de la ventana de 24 horas y para SMS y correo.
     */
    @Column(name = "provider_template_id", length = 64)
    private String providerTemplateId;

    /**
     * Orden de las variables separadas por coma. WhatsApp las numera ({{1}},
     * {{2}}) y templateContent las nombra (${name}): esta columna traduce de un
     * vocabulario al otro.
     */
    @Column(name = "provider_variables", length = 255)
    private String providerVariables;

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

