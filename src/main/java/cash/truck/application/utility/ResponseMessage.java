package cash.truck.application.utility;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.Pageable;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ResponseMessage {
    private Object data;
    private int code;
    private String message;
    private Pageable pagination;
    private String i18n;
}