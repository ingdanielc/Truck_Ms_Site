package cash.truck.domain.dtos.reports;

import java.math.BigDecimal;
import java.util.Map;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Los tipos de viaje y de gasto viajan como mapas por clave existente
 * (trip.tripType, category.expenseTypeId) y no como campos con nombre: un tipo
 * nuevo entra en el mapa sin desplegar backend.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReportMonthDTO {

    private int month;
    /** Hubo viaje o gasto. No se deduce de que los montos den cero. */
    private boolean activity;
    private BigDecimal freight;
    private Map<String, Long> tripsByType;
    /** Gastos con tripId de un viaje del mismo mes. */
    private BigDecimal tripExpenses;
    /** El resto de gastos del mes, por category.expenseTypeId. */
    private Map<Integer, BigDecimal> expensesByType;
}
