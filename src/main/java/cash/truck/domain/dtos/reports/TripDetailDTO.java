package cash.truck.domain.dtos.reports;

import java.math.BigDecimal;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * originId, destinationId, loadType y numberOfDays ya existen en trip; van
 * incluidos para habilitar detalles por ruta o duracion sin tocar el backend.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class TripDetailDTO {

    private Long id;
    private String numberTrip;
    private String plate;
    private int month;
    private BigDecimal freight;
    /** Gastos con este tripId fechados dentro del periodo consultado. */
    private BigDecimal expenses;
    private String originId;
    private String destinationId;
    private String loadType;
    private Integer numberOfDays;
}
