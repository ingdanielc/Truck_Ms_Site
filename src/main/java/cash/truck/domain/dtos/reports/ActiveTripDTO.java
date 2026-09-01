package cash.truck.domain.dtos.reports;

import java.math.BigDecimal;
import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** Viaje con status 'En Curso'. Sin filtro de fecha, igual que hoy. */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ActiveTripDTO {

    private Long tripId;
    private String numberTrip;
    private String plate;
    private String originId;
    private String destinationId;
    private Date startDate;
    private BigDecimal freight;
    private BigDecimal expenses;
}
