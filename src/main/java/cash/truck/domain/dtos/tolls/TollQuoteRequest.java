package cash.truck.domain.dtos.tolls;

import cash.truck.domain.enums.TripTypeEnum;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDate;

/**
 * Peticion de cotizacion de peajes para un trayecto.
 *
 * El bloque route es opcional. Cuando el cliente logra un trazado utilizable lo
 * reenvia y la cotizacion sigue la carretera real; cuando no —el proveedor no
 * devolvio geometria, o el trazado supera el corte de tamano— se omite y el
 * endpoint responde igual en modo degradado. Esa opcionalidad es deliberada:
 * la app nunca se queda sin respuesta por un fallo del proveedor de rutas.
 */
@Data
public class TollQuoteRequest {

    private GeoPoint origin;

    private GeoPoint destination;

    /** Solo se lee cuando tripType es REDONDO; en los demas tipos se ignora. */
    private GeoPoint returnDestination;

    private Long vehicleId;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate travelDate;

    /** Si no llega se asume CARGADO, igual que al guardar el viaje. */
    private TripTypeEnum tripType;

    private RouteInput route;

    /**
     * Punto del trayecto. cityId acompana a las coordenadas para que la
     * respuesta pueda relacionarse con el maestro de ciudades del viaje; el
     * emparejamiento de peajes se hace con lat/lng, no con el.
     */
    @Data
    public static class GeoPoint {
        private Double lat;
        private Double lng;
        private Integer cityId;
    }

    /**
     * Trazado calculado por el cliente.
     *
     * No trae duracion porque el proveedor de rutas no siempre la entrega junto
     * con la geometria; el backend la estima a partir de la distancia y una
     * velocidad promedio de carga configurada.
     */
    @Data
    public static class RouteInput {
        /** Quien calculo el trazado. Se devuelve tal cual para trazabilidad. */
        private String provider;
        private String encodedPolyline;
        private Long distanceMeters;
    }
}
