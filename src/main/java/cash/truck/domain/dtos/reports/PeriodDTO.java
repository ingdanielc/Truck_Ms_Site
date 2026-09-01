package cash.truck.domain.dtos.reports;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PeriodDTO {

    private int year;
    /** Nulo cuando el detalle abarca el ano completo. */
    private Integer month;
}
