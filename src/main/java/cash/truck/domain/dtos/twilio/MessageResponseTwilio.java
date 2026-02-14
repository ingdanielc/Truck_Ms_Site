package cash.truck.domain.dtos.twilio;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class MessageResponseTwilio {
    private String smsMessageSid;
    private String numMedia;
    private String profileName;
    private String messageType;
    private String smsSid;
    private String waId;
    private String smsStatus;
    private String body;
    private String to;
    private String numSegments;
    private String referralNumMedia;
    private String messageSid;
    private String accountSid;
    private String from;
    private String apiVersion;
}
