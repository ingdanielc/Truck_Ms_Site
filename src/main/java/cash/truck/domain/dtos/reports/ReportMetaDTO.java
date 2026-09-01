package cash.truck.domain.dtos.reports;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReportMetaDTO {

    private int year;
    /** Dimension del eje ya resuelta: vehicle, owner o driver. */
    private String groupBy;
    /** Zona en la que se agrego; el cliente no debe volver a convertir. */
    private String timezone;
}
