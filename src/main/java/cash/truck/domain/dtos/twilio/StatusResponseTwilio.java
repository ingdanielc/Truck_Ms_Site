package cash.truck.domain.dtos.twilio;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class StatusResponseTwilio {
    private String channelPrefix;
    private String apiVersion;
    private String messageStatus;
    private String smsSid;
    private String smsStatus;
    private String channelInstallSid;
    private String to;
    private String from;
    private String messageSid;
    private String accountSid;
    private String channelToAddress;
}

