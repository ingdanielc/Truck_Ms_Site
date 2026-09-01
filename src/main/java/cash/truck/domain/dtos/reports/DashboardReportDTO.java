package cash.truck.domain.dtos.reports;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Carga completa del tablero: el eje con sus doce meses por grupo y los viajes
 * en curso. Reemplaza las cuatro consultas masivas que hoy resuelve el cliente.
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DashboardReportDTO {

    private ReportMetaDTO meta;
    private List<ReportGroupDTO> groups;
    private List<ActiveTripDTO> activeTrips;
}
