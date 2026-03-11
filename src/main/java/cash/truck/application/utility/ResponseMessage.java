package cash.truck.application.utility;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ResponseMessage {
    private Object data;
    private int code;
    private String message;
    private Object pagination;
    private String i18n;
}