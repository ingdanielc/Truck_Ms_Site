package cash.truck.domain.dtos.reports;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Una barra del eje. La clave lleva el prefijo de la dimension
 * ("owner:14") para que el detalle sepa por donde filtrar sin parametros extra.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReportGroupDTO {

    private String key;
    private String label;
    private List<String> plates;
    /** Siempre 12 posiciones, indice 0 = enero. */
    private List<ReportMonthDTO> months;
}
