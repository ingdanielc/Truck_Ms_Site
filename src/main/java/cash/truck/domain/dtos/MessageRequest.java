package cash.truck.domain.dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class MessageRequest {
    private String medium; // optional por defecto Whastapp.
    private String messageType;
    private List<KeyValue> data;
    private List<String> recipients;
    private String content; // optional
    private String phone;
    private String email;
    private String attachmentUrl; // optional
    // WHATSAPP: plantilla aprobada. Los llena el caso de uso desde la plantilla
    // local; si vienen vacios se envia texto libre, como hasta ahora.
    private String contentSid; // optional
    private String contentVariables; // optional, JSON posicional {"1":"...","2":"..."}
    // EMAIL
    private String subject; // optional

    @Data
    public static class KeyValue {
        private String key;
        private String value;
    }
}
