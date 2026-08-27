package cash.truck.domain.dtos;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Respuesta de los pasos del flujo. Los campos no aplicables al paso se omiten
 * del JSON para que el front no tenga que interpretarlos.
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class PasswordResetResponse {
    /** Celular enmascarado, para indicar a donde se envio el codigo. */
    private String phone;
    private Integer expiresInMinutes;
    /** Solo en /verify: autoriza el cambio en /reset. */
    private String resetToken;
}
