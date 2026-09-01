package cash.truck.domain.dtos.reports;

import java.math.BigDecimal;
import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/** Detalle de un grupo. Se pide al tocar una barra, nunca en la carga. */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class GroupTripsReportDTO {

    private GroupRefDTO group;
    private PeriodDTO period;
    private List<TripDetailDTO> trips;
    /** Mantenimiento y gastos sin viaje del periodo. */
    private BigDecimal otherExpenses;
}
