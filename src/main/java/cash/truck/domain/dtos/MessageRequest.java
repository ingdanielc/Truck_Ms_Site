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
    // EMAIL
    private String subject; // optional

    @Data
    public static class KeyValue {
        private String key;
        private String value;
    }
}
