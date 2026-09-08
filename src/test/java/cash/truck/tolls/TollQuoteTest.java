package cash.truck.tolls;

import cash.truck.application.exception.RoutePayloadTooLargeException;
import cash.truck.application.exception.TripValidationException;
import cash.truck.application.usecases.TollUseCase;
import cash.truck.domain.dtos.tolls.TollQuoteRequest;
import cash.truck.domain.dtos.tolls.TollQuoteResponse;
import cash.truck.domain.entities.Toll;
import cash.truck.domain.entities.TollRate;
import cash.truck.domain.entities.Vehicle;
import cash.truck.domain.enums.RouteMatchModeEnum;
import cash.truck.domain.enums.TollRateSchemeEnum;
import cash.truck.domain.enums.TollRateStatusEnum;
import cash.truck.domain.enums.TripLegEnum;
import cash.truck.domain.enums.TripTypeEnum;
import cash.truck.domain.repositories.TollRateRepository;
import cash.truck.domain.repositories.TollRepository;
import cash.truck.domain.repositories.VehicleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyCollection;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * Reglas de la cotizacion de peajes.
 *
 * Se prueba contra dobles de los repositorios y no contra la base porque lo que
 * se quiere fijar es la decision —que entra en la ruta, con que tarifa y en que
 * orden—, no el mapeo JPA. Los datos van deliberadamente cerca de la ruta real
 * Bogota-Medellin para que las distancias sean las de un caso de verdad.
 */
class TollQuoteTest {

    private static final LocalDate TRAVEL_DATE = LocalDate.of(2026, 9, 7);

    private TollRepository tollRepository;
    private TollRateRepository tollRateRepository;
    private VehicleRepository vehicleRepository;
    private TollUseCase tollUseCase;

    @BeforeEach
    void setUp() {
        tollRepository = mock(TollRepository.class);
        tollRateRepository = mock(TollRateRepository.class);
        vehicleRepository = mock(VehicleRepository.class);
        tollUseCase = new TollUseCase(tollRepository, tollRateRepository, vehicleRepository);

        // Los mismos valores que declaran los perfiles; sin contexto de Spring
        // las @Value quedan en cero y ningun peaje entraria al corredor.
        ReflectionTestUtils.setField(tollUseCase, "matchToleranceKm", 2.0d);
        ReflectionTestUtils.setField(tollUseCase, "corridorKm", 30.0d);
        ReflectionTestUtils.setField(tollUseCase, "sinuosityFactor", 1.4d);
        ReflectionTestUtils.setField(tollUseCase, "averageSpeedKmh", 48.0d);
        ReflectionTestUtils.setField(tollUseCase, "maxEncodedPolylineLength", 200000);

        when(vehicleRepository.findById(123L)).thenReturn(Optional.of(vehicle(123L, "WGY123", "5")));
        when(tollRepository.countActiveWithoutCoordinates()).thenReturn(0L);
    }

    @Test
    void cotizaLosPeajesQueCaenSobreElTrazadoYDescartaElResto() {
        Toll onRoute = toll(15L, "Peaje A", 5.2005, -74.6003);
        Toll offRoute = toll(27L, "Peaje lejano", 10.9, -74.8);
        when(tollRepository.findActiveGeoReferenced()).thenReturn(List.of(onRoute, offRoute));
        when(tollRateRepository.findApplicableRates(anyCollection(), anyCollection(), any()))
                .thenReturn(List.of(rate(15L, "VI", 45000, LocalDate.of(2026, 6, 1), null)));

        TollQuoteResponse response = tollUseCase.quote(request(TripTypeEnum.CARGADO, bogotaMedellinPolyline(), 417300L));

        assertEquals(RouteMatchModeEnum.POLYLINE, response.getRoute().getMode());
        assertEquals("GOOGLE_ROUTES", response.getRoute().getProvider());
        assertEquals(new BigDecimal("417.3"), response.getRoute().getDistanceKm());
        // 417,3 km a los 48 km/h configurados: la duracion la estima el backend
        // porque el cliente envia distancia pero no tiempo.
        assertEquals(522, response.getRoute().getDurationMinutes());

        assertEquals(5, response.getVehicle().getNumberOfAxles());
        // Un camion de 5 ejes no tiene una categoria unica: depende de la estacion.
        assertEquals("VI", response.getVehicle().getTollCategories().get("OETR_7"));
        assertEquals("IV", response.getVehicle().getTollCategories().get("INVIAS_5"));

        assertEquals(1, response.getTolls().size());
        TollQuoteResponse.TollItem item = response.getTolls().get(0);
        assertEquals(15L, item.getId());
        assertEquals("Peaje A", item.getName());
        assertEquals(45000, item.getAmount());
        assertEquals(TollRateStatusEnum.VIGENTE, item.getRateStatus());
        assertEquals(TollRateSchemeEnum.OETR_7, item.getRateScheme());
        assertEquals("VI", item.getCategory());
        assertNull(item.getLeg(), "El tramo solo se informa en viaje redondo");
        assertEquals(45000L, response.getTotal());
    }

    /**
     * Los peajes salen en el orden en que el camion los encuentra, que no es el
     * orden en que el catalogo los devuelve.
     */
    @Test
    void losPeajesSalenEnElOrdenEnQueSeRecorreLaRuta() {
        Toll near = toll(15L, "Cercano al origen", 4.9005, -74.3003);
        Toll far = toll(27L, "Cercano al destino", 5.9005, -75.3003);
        when(tollRepository.findActiveGeoReferenced()).thenReturn(List.of(far, near));
        when(tollRateRepository.findApplicableRates(anyCollection(), anyCollection(), any()))
                .thenReturn(List.of(
                        rate(15L, "VI", 45000, LocalDate.of(2026, 6, 1), null),
                        rate(27L, "VI", 52000, LocalDate.of(2026, 6, 1), null)));

        TollQuoteResponse response = tollUseCase.quote(request(TripTypeEnum.CARGADO, bogotaMedellinPolyline(), 417300L));

        assertEquals(List.of("Cercano al origen", "Cercano al destino"),
                response.getTolls().stream().map(TollQuoteResponse.TollItem::getName).toList());
        assertEquals(97000L, response.getTotal());
    }

    /**
     * En redondo el trazado trae ida y regreso, asi que un peaje del corredor se
     * paga dos veces y tiene que aparecer una vez por tramo.
     */
    @Test
    void enViajeRedondoElMismoPeajeSeCobraEnCadaTramo() {
        Toll onRoute = toll(15L, "Peaje A", 5.2005, -74.6003);
        when(tollRepository.findActiveGeoReferenced()).thenReturn(List.of(onRoute));
        when(tollRateRepository.findApplicableRates(anyCollection(), anyCollection(), any()))
                .thenReturn(List.of(rate(15L, "VI", 45000, LocalDate.of(2026, 6, 1), null)));

        String roundTrip = RouteGeometryTest.encode(new double[][] {
                { 4.711, -74.072 }, { 5.2, -74.6 }, { 6.244, -75.581 }, { 5.2, -74.6 }, { 4.711, -74.072 }
        });
        TollQuoteRequest request = request(TripTypeEnum.REDONDO, roundTrip, 834600L);
        request.setReturnDestination(point(4.711, -74.072));

        TollQuoteResponse response = tollUseCase.quote(request);

        assertEquals(2, response.getTolls().size());
        assertEquals(TripLegEnum.IDA, response.getTolls().get(0).getLeg());
        assertEquals(TripLegEnum.REGRESO, response.getTolls().get(1).getLeg());
        assertEquals(90000L, response.getTotal());
    }

    /**
     * Sin trazado la consulta no falla: se degrada, avisa y sigue devolviendo
     * una estimacion, que es lo que mantiene viva la pantalla si el proveedor
     * de mapas no responde.
     */
    @Test
    void sinTrazadoResponderEnModoCorredorYAvisarlo() {
        Toll onRoute = toll(15L, "Peaje A", 5.4, -74.8);
        when(tollRepository.findActiveGeoReferenced()).thenReturn(List.of(onRoute));
        when(tollRateRepository.findApplicableRates(anyCollection(), anyCollection(), any()))
                .thenReturn(List.of(rate(15L, "VI", 45000, LocalDate.of(2026, 6, 1), null)));

        TollQuoteResponse response = tollUseCase.quote(request(TripTypeEnum.CARGADO, null, null));

        assertEquals(RouteMatchModeEnum.CORRIDOR, response.getRoute().getMode());
        assertEquals(1, response.getTolls().size());
        assertTrue(response.getWarnings().stream().anyMatch(w -> w.contains("línea recta")));
        // La recta son ~239 km; el factor de sinuosidad los lleva a ~334.
        assertTrue(response.getRoute().getDistanceKm().doubleValue() > 320
                && response.getRoute().getDistanceKm().doubleValue() < 350,
                "Distancia estimada inesperada: " + response.getRoute().getDistanceKm());
    }

    /**
     * El catalogo se alimenta de resoluciones con corte, asi que lo normal es
     * que la ultima tarifa conocida este vencida frente a un viaje futuro. Se
     * cotiza igual, pero marcada.
     */
    @Test
    void unaTarifaVencidaSeUsaPeroSeMarca() {
        Toll onRoute = toll(15L, "Peaje A", 5.2005, -74.6003);
        when(tollRepository.findActiveGeoReferenced()).thenReturn(List.of(onRoute));
        when(tollRateRepository.findApplicableRates(anyCollection(), anyCollection(), any()))
                .thenReturn(List.of(rate(15L, "VI", 45000,
                        LocalDate.of(2026, 6, 1), LocalDate.of(2026, 6, 30))));

        TollQuoteResponse response = tollUseCase.quote(request(TripTypeEnum.CARGADO, bogotaMedellinPolyline(), 417300L));

        assertEquals(TollRateStatusEnum.VENCIDA, response.getTolls().get(0).getRateStatus());
        assertEquals(45000L, response.getTotal());
        assertTrue(response.getWarnings().stream().anyMatch(w -> w.contains("vencida")));
    }

    /**
     * Una estacion sin tarifa se muestra igual: el camion va a pasar por ella y
     * esconderla haria creer que el trayecto cuesta menos.
     */
    @Test
    void unPeajeSinTarifaSeInformaPeroNoSuma() {
        Toll onRoute = toll(15L, "Peaje A", 5.2005, -74.6003);
        when(tollRepository.findActiveGeoReferenced()).thenReturn(List.of(onRoute));
        when(tollRateRepository.findApplicableRates(anyCollection(), anyCollection(), any())).thenReturn(List.of());

        TollQuoteResponse response = tollUseCase.quote(request(TripTypeEnum.CARGADO, bogotaMedellinPolyline(), 417300L));

        assertEquals(1, response.getTolls().size());
        assertNull(response.getTolls().get(0).getAmount());
        assertEquals(TollRateStatusEnum.SIN_TARIFA, response.getTolls().get(0).getRateStatus());
        assertEquals(0L, response.getTotal());
        assertTrue(response.getWarnings().stream().anyMatch(w -> w.contains("no tienen tarifa cargada")));
    }

    /**
     * Una misma ruta puede cruzar estaciones de las dos escalas, y el mismo
     * camion cambia de categoria al pasar de una a otra. Es el caso que rompia
     * el mapeo global anterior.
     */
    @Test
    void unaRutaConLasDosEscalasCotizaCadaPeajeEnLaSuya() {
        Toll siete = toll(15L, "Peaje OETR", 4.9005, -74.3003, TollRateSchemeEnum.OETR_7);
        Toll cinco = toll(27L, "Peaje INVIAS", 5.9005, -75.3003, TollRateSchemeEnum.INVIAS_5);
        when(tollRepository.findActiveGeoReferenced()).thenReturn(List.of(siete, cinco));
        when(tollRateRepository.findApplicableRates(anyCollection(), anyCollection(), any()))
                .thenReturn(List.of(
                        rate(15L, "VI", 91600, LocalDate.of(2026, 6, 1), null),
                        rate(27L, "IV", 43700, LocalDate.of(2026, 6, 1), null)));

        TollQuoteResponse response = tollUseCase.quote(request(TripTypeEnum.CARGADO, bogotaMedellinPolyline(), 417300L));

        assertEquals(2, response.getTolls().size());
        TollQuoteResponse.TollItem oetr = response.getTolls().get(0);
        TollQuoteResponse.TollItem invias = response.getTolls().get(1);
        assertEquals("VI", oetr.getCategory());
        assertEquals(91600, oetr.getAmount());
        assertEquals("IV", invias.getCategory());
        assertEquals(43700, invias.getAmount());
        assertEquals(135300L, response.getTotal());
    }

    /**
     * La consulta trae las categorias de las dos escalas a la vez; la fila de la
     * escala equivocada no se puede cobrar por descuido.
     */
    @Test
    void noSeCobraLaTarifaDeLaEscalaEquivocada() {
        Toll cinco = toll(15L, "Peaje INVIAS", 5.2005, -74.6003, TollRateSchemeEnum.INVIAS_5);
        when(tollRepository.findActiveGeoReferenced()).thenReturn(List.of(cinco));
        // Solo publica VI, que en la escala de cinco no le corresponde a este camion.
        when(tollRateRepository.findApplicableRates(anyCollection(), anyCollection(), any()))
                .thenReturn(List.of(rate(15L, "VI", 91600, LocalDate.of(2026, 6, 1), null)));

        TollQuoteResponse response = tollUseCase.quote(request(TripTypeEnum.CARGADO, bogotaMedellinPolyline(), 417300L));

        TollQuoteResponse.TollItem item = response.getTolls().get(0);
        assertEquals("IV", item.getCategory());
        assertNull(item.getAmount());
        assertEquals(TollRateStatusEnum.SIN_TARIFA, item.getRateStatus());
        assertEquals(0L, response.getTotal());
    }

    /**
     * Un camion de dos ejes bajo la escala de siete cae en IV por supuesto de
     * tamano de llanta. Es el unico caso que puede cobrar de mas, y se avisa.
     */
    @Test
    void dosEjesEnEscalaDeSieteAplicaLaCategoriaMayorYLoAdvierte() {
        when(vehicleRepository.findById(123L)).thenReturn(Optional.of(vehicle(123L, "WGY123", "2")));
        Toll siete = toll(15L, "Peaje OETR", 5.2005, -74.6003, TollRateSchemeEnum.OETR_7);
        when(tollRepository.findActiveGeoReferenced()).thenReturn(List.of(siete));
        when(tollRateRepository.findApplicableRates(anyCollection(), anyCollection(), any()))
                .thenReturn(List.of(rate(15L, "IV", 31700, LocalDate.of(2026, 6, 1), null)));

        TollQuoteResponse response = tollUseCase.quote(request(TripTypeEnum.CARGADO, bogotaMedellinPolyline(), 417300L));

        assertEquals("IV", response.getTolls().get(0).getCategory());
        assertEquals(31700, response.getTolls().get(0).getAmount());
        assertTrue(response.getWarnings().stream().anyMatch(w -> w.contains("dos ejes")));
    }

    /**
     * Regresion de EL BORDO: se devolvia SIN_TARIFA teniendo la tarifa cargada.
     *
     * La consulta trae las categorias de las dos escalas —para un camion de dos
     * ejes, IV de la de siete y II de la de cinco— y una estacion normalmente
     * tiene ambas. Al indexar las tarifas solo por estacion, la primera fila que
     * llegaba tapaba a la otra, y si esa era la de la escala ajena el peaje
     * quedaba sin importe. El orden de la lista lo reproduce: IV va primero.
     */
    @Test
    void unPeajeConLasDosCategoriasCargadasCotizaLaDeSuEscala() {
        when(vehicleRepository.findById(123L)).thenReturn(Optional.of(vehicle(123L, "WGY123", "2")));
        Toll elBordo = toll(43L, "EL BORDO", 5.2005, -74.6003, TollRateSchemeEnum.INVIAS_5);
        when(tollRepository.findActiveGeoReferenced()).thenReturn(List.of(elBordo));
        when(tollRateRepository.findApplicableRates(anyCollection(), anyCollection(), any()))
                .thenReturn(List.of(
                        rate(43L, "IV", 37900, LocalDate.of(2026, 1, 16), null),
                        rate(43L, "II", 14600, LocalDate.of(2026, 1, 16), null)));

        TollQuoteResponse response = tollUseCase.quote(request(TripTypeEnum.CARGADO, bogotaMedellinPolyline(), 417300L));

        TollQuoteResponse.TollItem item = response.getTolls().get(0);
        assertEquals("II", item.getCategory());
        assertEquals(14600, item.getAmount(), "Debe cobrar la II de su escala, no la IV de la otra");
        assertEquals(TollRateStatusEnum.VIGENTE, item.getRateStatus());
        assertEquals(14600L, response.getTotal());
    }

    /** Sin escala registrada se asume INVIAS_5, que es la que no llega a VII. */
    @Test
    void unaEstacionSinEscalaRegistradaSeTrataComoInvias5() {
        Toll sinEscala = toll(15L, "Peaje sin escala", 5.2005, -74.6003, null);
        when(tollRepository.findActiveGeoReferenced()).thenReturn(List.of(sinEscala));
        when(tollRateRepository.findApplicableRates(anyCollection(), anyCollection(), any()))
                .thenReturn(List.of(rate(15L, "IV", 43700, LocalDate.of(2026, 6, 1), null)));

        TollQuoteResponse response = tollUseCase.quote(request(TripTypeEnum.CARGADO, bogotaMedellinPolyline(), 417300L));

        assertEquals(TollRateSchemeEnum.INVIAS_5, response.getTolls().get(0).getRateScheme());
        assertEquals("IV", response.getTolls().get(0).getCategory());
        assertEquals(43700L, response.getTotal());
    }

    @Test
    void unTrazadoDemasiadoGrandeSeRechazaCon413() {
        ReflectionTestUtils.setField(tollUseCase, "maxEncodedPolylineLength", 10);

        assertThrows(RoutePayloadTooLargeException.class,
                () -> tollUseCase.quote(request(TripTypeEnum.CARGADO, bogotaMedellinPolyline(), 417300L)));
    }

    @Test
    void unVehiculoSinEjesNoSePuedeCotizar() {
        when(vehicleRepository.findById(123L)).thenReturn(Optional.of(vehicle(123L, "WGY123", null)));

        TripValidationException error = assertThrows(TripValidationException.class,
                () -> tollUseCase.quote(request(TripTypeEnum.CARGADO, bogotaMedellinPolyline(), 417300L)));

        assertTrue(error.getMessage().contains("número de ejes"));
    }

    @Test
    void unRedondoSinDestinoDeRegresoSeRechaza() {
        TollQuoteRequest request = request(TripTypeEnum.REDONDO, bogotaMedellinPolyline(), 417300L);

        assertThrows(TripValidationException.class, () -> tollUseCase.quote(request));
    }

    // ------------------------------------------------------------------ apoyo

    private String bogotaMedellinPolyline() {
        return RouteGeometryTest.encode(new double[][] {
                { 4.711, -74.072 }, { 4.9, -74.3 }, { 5.2, -74.6 }, { 5.9, -75.3 }, { 6.244, -75.581 }
        });
    }

    private TollQuoteRequest request(TripTypeEnum tripType, String encodedPolyline, Long distanceMeters) {
        TollQuoteRequest request = new TollQuoteRequest();
        request.setOrigin(point(4.711, -74.072));
        request.setDestination(point(6.244, -75.581));
        request.setVehicleId(123L);
        request.setTravelDate(TRAVEL_DATE);
        request.setTripType(tripType);

        if (encodedPolyline != null) {
            TollQuoteRequest.RouteInput route = new TollQuoteRequest.RouteInput();
            route.setProvider("GOOGLE_ROUTES");
            route.setEncodedPolyline(encodedPolyline);
            route.setDistanceMeters(distanceMeters);
            request.setRoute(route);
        }
        return request;
    }

    private TollQuoteRequest.GeoPoint point(double lat, double lng) {
        TollQuoteRequest.GeoPoint point = new TollQuoteRequest.GeoPoint();
        point.setLat(lat);
        point.setLng(lng);
        return point;
    }

    private Vehicle vehicle(Long id, String plate, String axles) {
        Vehicle vehicle = new Vehicle();
        vehicle.setId(id);
        vehicle.setPlate(plate);
        vehicle.setNumberOfAxles(axles);
        return vehicle;
    }

    private Toll toll(Long id, String name, double lat, double lng) {
        return toll(id, name, lat, lng, TollRateSchemeEnum.OETR_7);
    }

    private Toll toll(Long id, String name, double lat, double lng, TollRateSchemeEnum scheme) {
        Toll toll = new Toll();
        toll.setId(id);
        toll.setName(name);
        toll.setLatitude(BigDecimal.valueOf(lat));
        toll.setLongitude(BigDecimal.valueOf(lng));
        toll.setActive(true);
        toll.setRateScheme(scheme);
        return toll;
    }

    private TollRate rate(Long tollId, String category, int amount, LocalDate start, LocalDate end) {
        TollRate rate = new TollRate();
        rate.setTollId(tollId);
        rate.setCategory(category);
        rate.setRate(amount);
        rate.setStartDate(start);
        rate.setEndDate(end);
        return rate;
    }
}
