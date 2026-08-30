package cash.truck.domain.dtos;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

/**
 * Respuesta del registro publico. Se devuelve un resumen y no la entidad Owner
 * porque esta arrastra el usuario asociado, y con el la contrasena cifrada: en
 * un endpoint abierto eso no debe salir.
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class RegisterResponse {
    private Long id;
    private Integer userId;
    private String name;
    private String email;
    private String documentNumber;
    private String cellPhone;
    private Boolean isDriver;
    private Integer maxVehicles;
    /** La fija el servidor: hoy mas los meses por defecto de suscripcion. */
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDate subscriptionEndDate;
    /** Estado del usuario creado. El registro publico siempre queda activo. */
    private String status;
}
