package cash.truck.domain.enums;

import lombok.Getter;

@Getter
public enum MessageStatusEnum {
    PENDING(1, "Pending"),             // El mensaje está pendiente de ser enviado.
    SENT(2, "Sent"),                   // El mensaje ha sido enviado.
    DELIVERED(3, "Delivered"),         // El mensaje ha sido entregado correctamente (válido para WhatsApp/SMS).
    FAILED(4, "Failed"),               // El envío del mensaje ha fallado.
    READ(5, "Read"),                   // El mensaje ha sido leído (válido para WhatsApp).
    RESPONDED(6, "Responded"),         // Se recibió una respuesta al mensaje (válido para WhatsApp).
    ERROR(7, "Error");                 // Hubo un error durante el procesamiento.

    private final int code;
    private final String name;

    MessageStatusEnum(int code, String name) {
        this.code = code;
        this.name = name;
    }

    public static MessageStatusEnum fromCode(int code) {
        for (MessageStatusEnum status : MessageStatusEnum.values()) {
            if (status.getCode() == code) {
                return status;
            }
        }
        throw new IllegalArgumentException("Invalid code: " + code);
    }

    public static MessageStatusEnum fromName(String name) {
        for (MessageStatusEnum status : MessageStatusEnum.values()) {
            if (status.getName().equalsIgnoreCase(name)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Invalid name: " + name);
    }
}
