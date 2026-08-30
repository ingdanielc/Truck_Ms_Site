package cash.truck.domain.dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/** Respuesta del validador asincrono del formulario de registro. */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class AvailabilityResponse {
    /** documentNumber, email o cellPhone. */
    private String field;
    /** true cuando el valor no esta tomado por ninguna cuenta. */
    private boolean available;
}
