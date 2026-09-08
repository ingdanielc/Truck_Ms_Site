package cash.truck.application.usecases;

import cash.truck.application.exception.RoutePayloadTooLargeException;
import cash.truck.application.exception.TripValidationException;
import cash.truck.application.utility.GeoUtils;
import cash.truck.application.utility.RoutePath;
import cash.truck.domain.dtos.tolls.TollQuoteRequest;
import cash.truck.domain.dtos.tolls.TollQuoteResponse;
import cash.truck.domain.entities.Toll;
import cash.truck.domain.entities.TollRate;
import cash.truck.domain.entities.Vehicle;
import cash.truck.domain.enums.RouteMatchModeEnum;
import cash.truck.domain.enums.TollCategoryEnum;
import cash.truck.domain.enums.TollRateSchemeEnum;
import cash.truck.domain.enums.TollRateStatusEnum;
import cash.truck.domain.enums.TripLegEnum;
import cash.truck.domain.enums.TripTypeEnum;
import cash.truck.domain.repositories.TollRateRepository;
import cash.truck.domain.repositories.TollRepository;
import cash.truck.domain.repositories.VehicleRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.EnumMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Cotizacion de peajes de un trayecto.
 *
 * El backend no calcula rutas: el cliente ya resolvio el trazado con su
 * proveedor de mapas y lo reenvia codificado. Aqui solo se decodifica, se
 * pregunta que estaciones del catalogo caen sobre el y se les pone precio segun
 * la categoria del vehiculo y la fecha del viaje. Esa division evita una
 * segunda llamada facturada al proveedor y garantiza que el cobro se calcule
 * sobre la misma ruta que el usuario esta viendo en el mapa.
 *
 * Cuando no llega trazado la consulta no falla: se degrada al modo CORRIDOR,
 * que aproxima con la recta entre los extremos. Es menos exacto y se avisa como
 * tal, pero mantiene viva la pantalla ante un fallo del proveedor de mapas.
 */
@Slf4j
@Service
public class TollUseCase {

    /**
     * Ancho del corredor, en kilometros, con que se acepta un peaje sobre el
     * trazado real. Dos kilometros absorben la diferencia entre la coordenada
     * publicada de la estacion y el eje de la via sin llegar a capturar peajes
     * de una carretera paralela.
     */
    @Value("${truck.tolls.match-tolerance-km:2.0}")
    private double matchToleranceKm;

    /**
     * Ancho del corredor en modo degradado. Es mucho mayor porque la referencia
     * ya no es la carretera sino una recta: en terreno montanoso la via se
     * aparta decenas de kilometros de ella y un corredor angosto perderia casi
     * todas las estaciones.
     */
    @Value("${truck.tolls.corridor-km:30.0}")
    private double corridorKm;

    /**
     * Cuanto mas larga es la carretera que la linea recta. Solo se usa en modo
     * degradado, para no reportar una distancia que ningun camion recorre.
     */
    @Value("${truck.tolls.sinuosity-factor:1.4}")
    private double sinuosityFactor;

    /**
     * Velocidad promedio de un vehiculo de carga, para estimar la duracion.
     * El cliente envia distancia pero no tiempo, asi que el tiempo sale de
     * aqui; es un promedio de trayecto completo, ya descontando pendientes y
     * paradas, no una velocidad de crucero.
     */
    @Value("${truck.tolls.average-speed-kmh:48.0}")
    private double averageSpeedKmh;

    /**
     * Corte de tamano del trazado. El cliente ya recorta antes de enviar; esto
     * es la defensa del servidor para no decodificar una cadena arbitrariamente
     * grande llegada de otro consumidor.
     */
    @Value("${truck.tolls.max-encoded-polyline-length:200000}")
    private int maxEncodedPolylineLength;

    private static final Pattern AXLES_PATTERN = Pattern.compile("\\d{1,2}");

    private final TollRepository tollRepository;
    private final TollRateRepository tollRateRepository;
    private final VehicleRepository vehicleRepository;

    public TollUseCase(TollRepository tollRepository, TollRateRepository tollRateRepository,
            VehicleRepository vehicleRepository) {
        this.tollRepository = tollRepository;
        this.tollRateRepository = tollRateRepository;
        this.vehicleRepository = vehicleRepository;
    }

    public TollQuoteResponse quote(TollQuoteRequest request) {
        validate(request);

        TripTypeEnum tripType = request.getTripType() != null ? request.getTripType() : TripTypeEnum.CARGADO;
        LocalDate travelDate = request.getTravelDate() != null ? request.getTravelDate() : LocalDate.now();

        Vehicle vehicle = vehicleRepository.findById(request.getVehicleId())
                .orElseThrow(() -> new EntityNotFoundException("Vehicle not found"));
        int axles = resolveAxles(vehicle);

        // El vehiculo no tiene una categoria sino una por escala: el mismo camion
        // de cinco ejes es VI donde rige la escala de siete y IV donde la de cinco.
        Map<TollRateSchemeEnum, TollCategoryEnum> categories = new EnumMap<>(TollRateSchemeEnum.class);
        for (TollRateSchemeEnum scheme : TollRateSchemeEnum.values()) {
            categories.put(scheme, TollCategoryEnum.forAxles(axles, scheme));
        }

        List<String> warnings = new ArrayList<>();
        RoutePlan plan = buildRoutePlan(request, tripType, warnings);
        List<MatchedToll> matched = matchTolls(plan, warnings);

        TollQuoteResponse response = new TollQuoteResponse();
        response.setRoute(buildRouteSummary(plan));
        response.setVehicle(buildVehicleSummary(vehicle, axles, categories));
        response.setWarnings(warnings);
        applyRates(response, matched, categories, axles, travelDate, tripType);

        return response;
    }

    // ---------------------------------------------------------------- entrada

    private void validate(TollQuoteRequest request) {
        if (request == null) {
            throw new TripValidationException("La solicitud de peajes viene vacía.");
        }
        if (request.getVehicleId() == null) {
            throw new TripValidationException("El vehículo es obligatorio para cotizar los peajes.");
        }
        requireCoordinates(request.getOrigin(), "origen");
        requireCoordinates(request.getDestination(), "destino");

        // El destino de regreso solo se exige en redondo, igual que al guardar el viaje.
        if (request.getTripType() == TripTypeEnum.REDONDO) {
            requireCoordinates(request.getReturnDestination(), "destino de regreso");
        }
    }

    private void requireCoordinates(TollQuoteRequest.GeoPoint point, String label) {
        if (point == null || point.getLat() == null || point.getLng() == null) {
            throw new TripValidationException("Las coordenadas del " + label + " son obligatorias.");
        }
        if (point.getLat() < -90 || point.getLat() > 90 || point.getLng() < -180 || point.getLng() > 180) {
            throw new TripValidationException("Las coordenadas del " + label + " están fuera de rango.");
        }
    }

    /**
     * Numero de ejes del vehiculo. La columna es texto libre, asi que se lee el
     * primer numero que aparezca y se ignora lo demas: en la base conviven "3"
     * y "3 ejes" para el mismo dato.
     *
     * Sin ejes no hay categoria y sin categoria no hay tarifa, asi que se corta
     * con un mensaje que dice que corregir, en lugar de cotizar con un valor
     * inventado.
     */
    private int resolveAxles(Vehicle vehicle) {
        String raw = vehicle.getNumberOfAxles();
        if (raw != null) {
            Matcher matcher = AXLES_PATTERN.matcher(raw);
            if (matcher.find()) {
                int axles = Integer.parseInt(matcher.group());
                if (axles > 0) {
                    return axles;
                }
            }
        }
        throw new TripValidationException("El vehículo con placa "
                + (vehicle.getPlate() != null ? vehicle.getPlate().toUpperCase() : vehicle.getId())
                + " no tiene un número de ejes válido registrado; sin ese dato no se puede determinar"
                + " la categoría de peaje.");
    }

    // ------------------------------------------------------------------ ruta

    private RoutePlan buildRoutePlan(TollQuoteRequest request, TripTypeEnum tripType, List<String> warnings) {
        TollQuoteRequest.RouteInput route = request.getRoute();
        String encoded = route != null ? route.getEncodedPolyline() : null;

        if (encoded != null && !encoded.isBlank()) {
            if (encoded.length() > maxEncodedPolylineLength) {
                throw new RoutePayloadTooLargeException("El trazado enviado supera el máximo de "
                        + maxEncodedPolylineLength + " caracteres. Reenvíe la solicitud sin el bloque route.");
            }
            List<double[]> points;
            try {
                points = GeoUtils.decodePolyline(encoded);
            } catch (IllegalArgumentException e) {
                log.warn("Trazado no decodificable en la cotización de peajes: {}", e.getMessage());
                points = List.of();
            }
            if (points.size() >= 2) {
                return polylinePlan(points, request, tripType, warnings);
            }
            warnings.add("El trazado recibido no era utilizable; los peajes se estimaron sobre la línea recta"
                    + " entre los puntos del trayecto.");
        }

        return corridorPlan(request, tripType, warnings);
    }

    /**
     * Plan sobre el trazado real.
     *
     * En viaje redondo el cliente pide ida y regreso en una sola ruta, con el
     * destino como punto intermedio, de modo que llega una sola polilinea que
     * cubre los dos tramos. Se parte por el vertice mas cercano al destino, que
     * es donde el camion da la vuelta: hasta ahi es IDA y de ahi en adelante
     * REGRESO. Partirlo importa porque un peaje que esta en los dos tramos se
     * paga dos veces y tiene que aparecer dos veces.
     */
    private RoutePlan polylinePlan(List<double[]> points, TollQuoteRequest request, TripTypeEnum tripType,
            List<String> warnings) {
        RoutePath full = new RoutePath(points);
        List<RouteLeg> legs = new ArrayList<>();

        if (tripType == TripTypeEnum.REDONDO && hasCoordinates(request.getReturnDestination())) {
            int turnaround = full.nearestVertexIndex(request.getDestination().getLat(),
                    request.getDestination().getLng());
            RoutePath outbound = full.slice(0, turnaround);
            RoutePath inbound = full.slice(turnaround, full.size() - 1);
            if (outbound != null && inbound != null) {
                legs.add(new RouteLeg(TripLegEnum.IDA, outbound));
                legs.add(new RouteLeg(TripLegEnum.REGRESO, inbound));
            } else {
                // El trazado no llega hasta el punto de retorno: se cotiza entero como un
                // solo tramo antes que perder la mitad de los peajes por no poder partirlo.
                legs.add(new RouteLeg(null, full));
                warnings.add("El trazado recibido no permitió separar la ida del regreso;"
                        + " los peajes se cotizaron como un único tramo.");
            }
        } else {
            legs.add(new RouteLeg(null, full));
        }

        TollQuoteRequest.RouteInput route = request.getRoute();
        Long distanceMeters = route != null ? route.getDistanceMeters() : null;
        double distanceKm = distanceMeters != null && distanceMeters > 0
                ? distanceMeters / 1000d
                : full.totalKm();
        String provider = route != null ? route.getProvider() : null;

        return new RoutePlan(RouteMatchModeEnum.POLYLINE, provider, legs, distanceKm, matchToleranceKm);
    }

    /**
     * Plan degradado: rectas entre los puntos del trayecto.
     *
     * La distancia se infla por el factor de sinuosidad porque la recta
     * subestima siempre —y en Colombia lo hace por mucho—; reportar la recta
     * pelada daria una duracion imposible de cumplir.
     */
    private RoutePlan corridorPlan(TollQuoteRequest request, TripTypeEnum tripType, List<String> warnings) {
        List<RouteLeg> legs = new ArrayList<>();
        TollQuoteRequest.GeoPoint origin = request.getOrigin();
        TollQuoteRequest.GeoPoint destination = request.getDestination();

        boolean roundTrip = tripType == TripTypeEnum.REDONDO && hasCoordinates(request.getReturnDestination());
        legs.add(new RouteLeg(roundTrip ? TripLegEnum.IDA : null,
                RoutePath.straightLine(origin.getLat(), origin.getLng(),
                        destination.getLat(), destination.getLng())));

        if (roundTrip) {
            TollQuoteRequest.GeoPoint returnDestination = request.getReturnDestination();
            legs.add(new RouteLeg(TripLegEnum.REGRESO,
                    RoutePath.straightLine(destination.getLat(), destination.getLng(),
                            returnDestination.getLat(), returnDestination.getLng())));
        }

        double straightKm = legs.stream().mapToDouble(leg -> leg.path().totalKm()).sum();
        warnings.add("No se recibió el trazado de la ruta: la distancia y los peajes son una estimación"
                + " sobre la línea recta del trayecto.");

        return new RoutePlan(RouteMatchModeEnum.CORRIDOR, null, legs, straightKm * sinuosityFactor, corridorKm);
    }

    private boolean hasCoordinates(TollQuoteRequest.GeoPoint point) {
        return point != null && point.getLat() != null && point.getLng() != null;
    }

    // ------------------------------------------------------------------ peajes

    /**
     * Estaciones que caen dentro del corredor, en el orden en que el camion las
     * encuentra.
     *
     * El orden es por tramo y luego por avance sobre la ruta, no por cercania
     * ni por nombre: es la secuencia real de casetas del viaje, que es como el
     * conductor las va a ir pagando.
     */
    private List<MatchedToll> matchTolls(RoutePlan plan, List<String> warnings) {
        List<Toll> candidates = tollRepository.findActiveGeoReferenced();
        long withoutCoordinates = tollRepository.countActiveWithoutCoordinates();
        if (withoutCoordinates > 0) {
            warnings.add(withoutCoordinates + " estación(es) de peaje del catálogo no tienen coordenadas"
                    + " registradas y no se pueden ubicar sobre la ruta.");
        }

        List<MatchedToll> matched = new ArrayList<>();
        for (RouteLeg leg : plan.legs()) {
            for (Toll toll : candidates) {
                double lat = toll.getLatitude().doubleValue();
                double lng = toll.getLongitude().doubleValue();
                if (!leg.path().withinBounds(lat, lng, plan.toleranceKm())) {
                    continue;
                }
                RoutePath.Match match = leg.path().nearest(lat, lng);
                if (match.distanceKm() <= plan.toleranceKm()) {
                    matched.add(new MatchedToll(toll, leg.leg(), match.distanceKm(), match.alongKm()));
                }
            }
        }

        matched.sort(Comparator
                .comparingInt((MatchedToll match) -> match.leg() == TripLegEnum.REGRESO ? 1 : 0)
                .thenComparingDouble(MatchedToll::alongKm));
        return matched;
    }

    // ------------------------------------------------------------------ tarifas

    /**
     * Pone precio a cada estacion emparejada y arma el total.
     *
     * La categoria se resuelve por estacion, no una sola vez para todo el viaje:
     * una misma ruta puede cruzar peajes que cobran bajo escalas distintas, y el
     * mismo camion cambia de categoria al pasar de uno al otro.
     *
     * Una estacion sin tarifa para su categoria se devuelve igual, con importe
     * nulo y marcada: el conductor va a pasar por esa caseta y va a pagar algo,
     * y esconderla haria creer que el trayecto es mas barato. Queda visible pero
     * fuera del total.
     */
    private void applyRates(TollQuoteResponse response, List<MatchedToll> matched,
            Map<TollRateSchemeEnum, TollCategoryEnum> categories, int axles, LocalDate travelDate,
            TripTypeEnum tripType) {
        if (matched.isEmpty()) {
            return;
        }

        Set<Long> tollIds = new LinkedHashSet<>();
        for (MatchedToll match : matched) {
            tollIds.add(match.toll().getId());
        }

        Map<RateKey, TollRate> rates = selectRates(tollIds, categories, travelDate);

        long total = 0L;
        int expired = 0;
        int missing = 0;
        int assumed = 0;

        for (MatchedToll match : matched) {
            Toll toll = match.toll();
            TollRateSchemeEnum scheme = schemeOf(toll);
            TollCategoryEnum category = categories.get(scheme);
            TollRate rate = rates.get(new RateKey(toll.getId(), category));

            TollQuoteResponse.TollItem item = new TollQuoteResponse.TollItem();
            item.setId(toll.getId());
            item.setName(toll.getName());
            item.setDepartment(toll.getDepartment());
            item.setMunicipality(toll.getMunicipality());
            item.setRateScheme(scheme);
            item.setCategory(category.name());
            item.setLeg(tripType == TripTypeEnum.REDONDO ? match.leg() : null);
            item.setDistanceFromRouteKm(round(match.distanceKm(), 2));

            if (TollCategoryEnum.isAxleSizeAssumption(axles, scheme)) {
                assumed++;
            }

            if (rate == null) {
                item.setRateStatus(TollRateStatusEnum.SIN_TARIFA);
                missing++;
            } else {
                item.setAmount(rate.getRate());
                total += rate.getRate();
                boolean current = rate.getEndDate() == null || !rate.getEndDate().isBefore(travelDate);
                item.setRateStatus(current ? TollRateStatusEnum.VIGENTE : TollRateStatusEnum.VENCIDA);
                if (!current) {
                    expired++;
                }
            }

            response.getTolls().add(item);
        }

        response.setTotal(total);

        if (expired > 0) {
            response.getWarnings().add(expired + " peaje(s) se cotizaron con la última tarifa conocida,"
                    + " ya vencida a la fecha del viaje.");
        }
        if (missing > 0) {
            response.getWarnings().add(missing + " peaje(s) de la ruta no tienen tarifa cargada para la"
                    + " categoría que les corresponde y no suman al total.");
        }
        if (assumed > 0) {
            response.getWarnings().add(assumed + " peaje(s) parten los camiones de dos ejes en dos"
                    + " categorías según el tamaño de la llanta trasera. Se aplicó la mayor, así que"
                    + " ese valor puede quedar por encima del real.");
        }
    }

    /**
     * Tarifa vigente por estacion y categoria.
     *
     * Se pide en una sola consulta la categoria de las dos escalas porque los
     * peajes de una misma ruta pueden regirse por escalas distintas; cual de las
     * dos filas aplica a cada estacion se decide despues, contra su rateScheme.
     *
     * Por eso el indice es (estacion, categoria) y no solo la estacion: una
     * estacion normalmente tiene cargadas las dos categorias consultadas, y
     * quedarse con una sola fila por estacion descartaria la correcta cada vez
     * que la otra escala llegara primero. Con las dos indexadas, el llamador
     * pide exactamente la que le corresponde.
     *
     * Dentro de cada categoria se conserva la mas reciente ya iniciada: la
     * consulta llega ordenada por fecha descendente, asi que basta la primera.
     * No se exige vigencia estricta a proposito —el catalogo se alimenta de
     * resoluciones con corte— y una tarifa vencida se usa marcada antes que
     * dejar el peaje sin importe.
     */
    private Map<RateKey, TollRate> selectRates(Set<Long> tollIds,
            Map<TollRateSchemeEnum, TollCategoryEnum> categories, LocalDate travelDate) {
        Set<String> codes = new LinkedHashSet<>();
        for (TollCategoryEnum category : categories.values()) {
            codes.add(category.name());
        }

        Map<RateKey, TollRate> best = new HashMap<>();
        for (TollRate rate : tollRateRepository.findApplicableRates(tollIds, codes, travelDate)) {
            TollCategoryEnum category = TollCategoryEnum.fromCode(rate.getCategory());
            if (category != null) {
                best.putIfAbsent(new RateKey(rate.getTollId(), category), rate);
            }
        }
        return best;
    }

    /** Escala de la estacion. Un nulo se lee como INVIAS_5: es la escala que no llega a VII. */
    private TollRateSchemeEnum schemeOf(Toll toll) {
        return toll.getRateScheme() != null ? toll.getRateScheme() : TollRateSchemeEnum.INVIAS_5;
    }

    // ----------------------------------------------------------------- respuesta

    private TollQuoteResponse.RouteSummary buildRouteSummary(RoutePlan plan) {
        TollQuoteResponse.RouteSummary summary = new TollQuoteResponse.RouteSummary();
        summary.setMode(plan.mode());
        summary.setProvider(plan.provider());
        summary.setDistanceKm(round(plan.distanceKm(), 1));
        summary.setDurationMinutes(estimateDurationMinutes(plan.distanceKm()));
        summary.setMatchToleranceKm(round(plan.toleranceKm(), 1));
        return summary;
    }

    private TollQuoteResponse.VehicleSummary buildVehicleSummary(Vehicle vehicle, int axles,
            Map<TollRateSchemeEnum, TollCategoryEnum> categories) {
        TollQuoteResponse.VehicleSummary summary = new TollQuoteResponse.VehicleSummary();
        summary.setId(vehicle.getId());
        summary.setNumberOfAxles(axles);
        categories.forEach((scheme, category) -> summary.getTollCategories().put(scheme.name(), category.name()));
        return summary;
    }

    private Integer estimateDurationMinutes(double distanceKm) {
        if (averageSpeedKmh <= 0) {
            return null;
        }
        return (int) Math.round(distanceKm / averageSpeedKmh * 60d);
    }

    private BigDecimal round(double value, int scale) {
        return BigDecimal.valueOf(value).setScale(scale, RoundingMode.HALF_UP);
    }

    // ---------------------------------------------------------------- auxiliares

    /** Un tramo del trayecto con su trazado. leg es nulo cuando el viaje no es redondo. */
    private record RouteLeg(TripLegEnum leg, RoutePath path) {
    }

    /** Como quedo resuelta la ruta: modo, tramos, distancia total y ancho del corredor. */
    private record RoutePlan(RouteMatchModeEnum mode, String provider, List<RouteLeg> legs, double distanceKm,
            double toleranceKm) {
    }

    /** Una estacion ubicada sobre un tramo, con su distancia al trazado y su avance. */
    private record MatchedToll(Toll toll, TripLegEnum leg, double distanceKm, double alongKm) {
    }

    /**
     * Indice de una tarifa: la estacion y la categoria juntas.
     *
     * La categoria forma parte de la llave porque una estacion tiene tarifa para
     * varias, y la consulta trae mas de una por estacion a proposito.
     */
    private record RateKey(Long tollId, TollCategoryEnum category) {
    }
}
