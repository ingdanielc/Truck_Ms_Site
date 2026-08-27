package cash.truck.domain.dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Cuerpo unico de los tres pasos: /forgotPassword usa cellPhone, /verify usa
 * cellPhone + code y /reset usa resetToken + password.
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class PasswordResetRequest {
    private String cellPhone;
    private String code;
    private String resetToken;
    private String password;
}
