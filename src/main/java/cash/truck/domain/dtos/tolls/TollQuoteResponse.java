package cash.truck.domain.dtos.tolls;

import cash.truck.domain.enums.RouteMatchModeEnum;
import cash.truck.domain.enums.TollRateSchemeEnum;
import cash.truck.domain.enums.TripLegEnum;
import cash.truck.domain.enums.TollRateStatusEnum;
import lombok.Data;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Peajes que encuentra un trayecto, con su costo para la categoria del vehiculo. */
@Data
public class TollQuoteResponse {

    private RouteSummary route;
    private VehicleSummary vehicle;
    private List<TollItem> tolls = new ArrayList<>();

    /** Suma de los importes cotizados. Las estaciones sin tarifa no suman. */
    private Long total = 0L;

    /**
     * Avisos sobre la calidad del resultado: tarifas vencidas, estaciones sin
     * tarifa, catalogo sin georreferenciar, modo degradado.
     *
     * Van como texto y no como codigos porque son para que el cliente los
     * muestre al usuario, no para que ramifique logica sobre ellos: lo que si
     * es accionable —el modo y el estado de cada tarifa— ya viaja tipado.
     */
    private List<String> warnings = new ArrayList<>();

    @Data
    public static class RouteSummary {
        private RouteMatchModeEnum mode;
        private String provider;
        private BigDecimal distanceKm;
        private Integer durationMinutes;
        /** Distancia maxima a la ruta con que se acepto un peaje, en kilometros. */
        private BigDecimal matchToleranceKm;
    }

    @Data
    public static class VehicleSummary {
        private Long id;
        private Integer numberOfAxles;

        /**
         * Categoria del vehiculo en cada escala tarifaria, p. ej.
         * {"OETR_7":"VI","INVIAS_5":"IV"}.
         *
         * No es un solo valor porque el vehiculo no tiene una categoria unica:
         * el mismo camion de cinco ejes es VI en unas estaciones y IV en otras.
         * La que se aplico a cada peaje viaja en tolls[].category.
         */
        private Map<String, String> tollCategories = new LinkedHashMap<>();
    }

    @Data
    public static class TollItem {
        private Long id;
        private String name;
        private String department;
        private String municipality;
        /** Escala tarifaria de esta estacion. Es la que da sentido a category. */
        private TollRateSchemeEnum rateScheme;
        /** Categoria aplicada, dentro de la escala de esta estacion. */
        private String category;
        /** Nulo si la estacion no tiene tarifa cargada para esa categoria. */
        private Integer amount;
        private TollRateStatusEnum rateStatus;
        /** Solo se informa en viaje REDONDO, donde el mismo peaje puede cobrarse dos veces. */
        private TripLegEnum leg;
        private BigDecimal distanceFromRouteKm;
    }
}
