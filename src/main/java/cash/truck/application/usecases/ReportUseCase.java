package cash.truck.application.usecases;

import cash.truck.application.exception.ReportException;
import cash.truck.application.utility.Constants;
import cash.truck.domain.dtos.reports.ActiveTripDTO;
import cash.truck.domain.dtos.reports.DashboardReportDTO;
import cash.truck.domain.dtos.reports.GroupRefDTO;
import cash.truck.domain.dtos.reports.GroupTripsReportDTO;
import cash.truck.domain.dtos.reports.PeriodDTO;
import cash.truck.domain.dtos.reports.ReportGroupDTO;
import cash.truck.domain.dtos.reports.ReportMetaDTO;
import cash.truck.domain.dtos.reports.ReportMonthDTO;
import cash.truck.domain.dtos.reports.TripDetailDTO;
import cash.truck.domain.entities.Driver;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.entities.Users;
import cash.truck.domain.enums.TripTypeEnum;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.ExpenseRepository;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.TripRepository;
import cash.truck.domain.repositories.UsersRepository;
import cash.truck.domain.repositories.VehicleRepository;
import cash.truck.domain.repositories.VehicleRepository.ScopeVehicleRow;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

/**
 * Carga del tablero y detalle de un grupo. Las agregaciones bajan a SQL al
 * grano vehiculo/conductor/mes y aqui solo se pliegan a la dimension pedida:
 * asi la regla de a quien pertenece un viaje —driver.ownerId con respaldo en el
 * propietario del vehiculo— vive en un unico lugar para las tres dimensiones.
 *
 * El alcance sale siempre de la identidad de quien consulta, nunca de los
 * parametros: el propietario ve sus vehiculos, el conductor los que tenga
 * asignados y el administrador todos.
 */
@Service
@Transactional
public class ReportUseCase {

    public static final String GROUP_VEHICLE = "vehicle";
    public static final String GROUP_OWNER = "owner";
    public static final String GROUP_DRIVER = "driver";

    private static final int MONTHS_IN_YEAR = 12;
    /** Sin filtro. Se usa en lugar de nulos para no depender de como los tipa MySQL. */
    private static final int ALL_MONTHS = -1;
    private static final long NO_FILTER = -1L;

    private final VehicleRepository vehicleRepository;
    private final TripRepository tripRepository;
    private final ExpenseRepository expenseRepository;
    private final OwnerRepository ownerRepository;
    private final DriverRepository driverRepository;
    private final UsersRepository usersRepository;
    private final SecurityUseCase securityUseCase;

    public ReportUseCase(VehicleRepository vehicleRepository,
            TripRepository tripRepository,
            ExpenseRepository expenseRepository,
            OwnerRepository ownerRepository,
            DriverRepository driverRepository,
            UsersRepository usersRepository,
            SecurityUseCase securityUseCase) {
        this.vehicleRepository = vehicleRepository;
        this.tripRepository = tripRepository;
        this.expenseRepository = expenseRepository;
        this.ownerRepository = ownerRepository;
        this.driverRepository = driverRepository;
        this.usersRepository = usersRepository;
        this.securityUseCase = securityUseCase;
    }

    // ---------------------------------------------------------------- Endpoint A

    public DashboardReportDTO buildDashboard(Integer callerUserId, String jwt, int year, String groupBy, Long ownerId) {
        validateYear(year);
        Scope scope = resolveScope(callerUserId, jwt, ownerId);
        String dimension = resolveDimension(groupBy, scope.defaultGroupBy);
        ReportMetaDTO meta = new ReportMetaDTO(year, dimension, Constants.ZONE_BOGOTA);

        if (scope.vehicleIds.isEmpty()) {
            return new DashboardReportDTO(meta, new ArrayList<>(), new ArrayList<>());
        }

        Map<String, GroupAccumulator> groups = new LinkedHashMap<>();

        // El eje se siembra con todo el alcance para que un grupo sin movimiento
        // aparezca en cero en lugar de desaparecer de la grafica.
        for (ScopeVehicleRow vehicle : scope.vehicles) {
            String key = groupKeyForVehicle(dimension, vehicle);
            if (key != null) {
                accumulator(groups, key).plates.add(vehicle.getPlate());
            }
        }

        for (TripRepository.TripMonthRow row : tripRepository.aggregateTripsByMonth(year, scope.vehicleIds)) {
            Long vehicleId = toLong(row.getVehicleId());
            String key = groupKeyForTrip(dimension, toLong(row.getDriverId()), toLong(row.getDriverOwnerId()),
                    scope.byVehicleId.get(vehicleId));
            if (key == null) {
                continue;
            }
            GroupAccumulator group = accumulator(groups, key);
            group.plates.add(plateOf(scope, vehicleId));
            MonthAccumulator month = group.month(toInt(row.getMonthIndex()));
            month.activity = true;
            month.freight = month.freight.add(nullSafe(row.getFreight()));
            month.tripsByType.merge(normalizeTripType(row.getTripType()), toLong(row.getTrips()), Long::sum);
        }

        for (ExpenseRepository.TripExpenseMonthRow row : expenseRepository.aggregateTripExpensesByMonth(year,
                scope.vehicleIds)) {
            Long vehicleId = toLong(row.getVehicleId());
            String key = groupKeyForTrip(dimension, toLong(row.getDriverId()), toLong(row.getDriverOwnerId()),
                    scope.byVehicleId.get(vehicleId));
            if (key == null) {
                continue;
            }
            GroupAccumulator group = accumulator(groups, key);
            group.plates.add(plateOf(scope, vehicleId));
            MonthAccumulator month = group.month(toInt(row.getMonthIndex()));
            month.activity = true;
            month.tripExpenses = month.tripExpenses.add(nullSafe(row.getAmount()));
        }

        for (ExpenseRepository.OtherExpenseMonthRow row : expenseRepository.aggregateOtherExpensesByMonth(year,
                scope.vehicleIds)) {
            Long vehicleId = toLong(row.getVehicleId());
            String key = groupKeyForVehicle(dimension, scope.byVehicleId.get(vehicleId));
            if (key == null) {
                continue;
            }
            GroupAccumulator group = accumulator(groups, key);
            group.plates.add(plateOf(scope, vehicleId));
            MonthAccumulator month = group.month(toInt(row.getMonthIndex()));
            month.activity = true;
            month.expensesByType.merge(toInt(row.getExpenseTypeId()), nullSafe(row.getAmount()), BigDecimal::add);
        }

        Map<String, String> labels = resolveLabels(dimension, groups.keySet(), scope);
        List<ReportGroupDTO> result = groups.values().stream()
                .map(group -> group.toDto(labels.getOrDefault(group.key, group.key)))
                .sorted(Comparator.comparing(ReportGroupDTO::getLabel, String.CASE_INSENSITIVE_ORDER))
                .collect(Collectors.toList());

        return new DashboardReportDTO(meta, result, activeTrips(scope));
    }

    private List<ActiveTripDTO> activeTrips(Scope scope) {
        return tripRepository.findActiveTrips(Constants.TRIP_STATUS_IN_PROGRESS, scope.vehicleIds).stream()
                .map(row -> new ActiveTripDTO(toLong(row.getTripId()), row.getNumberTrip(), row.getPlate(),
                        row.getOriginId(), row.getDestinationId(), row.getStartDate(),
                        nullSafe(row.getFreight()), nullSafe(row.getExpenses())))
                .collect(Collectors.toList());
    }

    // ---------------------------------------------------------------- Endpoint B

    public GroupTripsReportDTO buildGroupTrips(Integer callerUserId, String jwt, String key, int year, Integer month) {
        validateYear(year);
        if (month != null && (month < 0 || month >= MONTHS_IN_YEAR)) {
            throw ReportException.invalidParameter("El mes debe estar entre 0 y 11.");
        }
        GroupKey group = parseKey(key);
        Scope scope = resolveScope(callerUserId, jwt, null);
        int monthFilter = month == null ? ALL_MONTHS : month;

        List<TripRepository.TripDetailRow> rows = scope.vehicleIds.isEmpty()
                ? List.of()
                : tripRepository.findGroupTrips(year, monthFilter, group.type(), group.id(), scope.vehicleIds);

        // Un grupo que ni pertenece al alcance ni produjo viajes dentro de el no
        // se responde en vacio: eso confirmaria su existencia a quien no lo ve.
        if (rows.isEmpty() && !scopeGroupKeys(scope, group.type()).contains(group.key())) {
            throw ReportException.groupOutOfScope(key);
        }

        List<TripDetailDTO> trips = rows.stream()
                .map(row -> new TripDetailDTO(toLong(row.getId()), row.getNumberTrip(), row.getPlate(),
                        toInt(row.getMonthIndex()), nullSafe(row.getFreight()), nullSafe(row.getExpenses()),
                        row.getOriginId(), row.getDestinationId(), row.getLoadType(),
                        row.getNumberOfDays() == null ? null : row.getNumberOfDays().intValue()))
                .collect(Collectors.toList());

        BigDecimal otherExpenses = scope.vehicleIds.isEmpty()
                ? BigDecimal.ZERO
                : nullSafe(expenseRepository.sumOtherExpensesForGroup(year, monthFilter, group.type(), group.id(),
                        scope.vehicleIds));

        String label = resolveLabels(group.type(), Set.of(group.key()), scope).getOrDefault(group.key(), group.key());

        return new GroupTripsReportDTO(new GroupRefDTO(group.key(), label), new PeriodDTO(year, month), trips,
                otherExpenses);
    }

    // ---------------------------------------------------------------- Alcance

    /**
     * Vehiculos que puede ver quien consulta y dimension por omision del eje.
     * El administrador ve todo y solo el puede acotar por propietario; para el
     * resto el parametro ownerId se ignora porque el alcance ya viene dado.
     */
    private Scope resolveScope(Integer callerUserId, String jwt, Long ownerId) {
        Integer userId = securityUseCase.resolveCallerUserId(callerUserId, jwt);
        if (userId == null) {
            throw ReportException.unresolvedCaller();
        }
        Users user = usersRepository.findById(userId).orElseThrow(ReportException::unresolvedCaller);

        if (securityUseCase.isAdministrator(user)) {
            long ownerFilter = ownerId != null ? ownerId : NO_FILTER;
            return new Scope(vehicleRepository.findScopeVehicles(ownerFilter, NO_FILTER), GROUP_OWNER);
        }

        Optional<Owner> owner = ownerRepository.findByUserId(userId);
        if (owner.isPresent()) {
            return new Scope(vehicleRepository.findScopeVehicles(owner.get().getId(), NO_FILTER), GROUP_VEHICLE);
        }

        Optional<Driver> driver = driverRepository.findFirstByUserId(userId);
        if (driver.isPresent()) {
            return new Scope(vehicleRepository.findScopeVehicles(NO_FILTER, driver.get().getId()), GROUP_VEHICLE);
        }

        // Usuario valido sin propietario ni conductor asociado: alcance vacio.
        return new Scope(List.of(), GROUP_VEHICLE);
    }

    private String resolveDimension(String groupBy, String fallback) {
        if (groupBy == null || groupBy.isBlank()) {
            return fallback;
        }
        String dimension = groupBy.trim().toLowerCase();
        if (!GROUP_VEHICLE.equals(dimension) && !GROUP_OWNER.equals(dimension) && !GROUP_DRIVER.equals(dimension)) {
            throw ReportException.invalidParameter("groupBy debe ser vehicle, owner o driver.");
        }
        return dimension;
    }

    private void validateYear(int year) {
        if (year < 2000 || year > 2999) {
            throw ReportException.invalidParameter("El ano debe ser de cuatro digitos.");
        }
    }

    // ---------------------------------------------------------------- Claves

    /**
     * Grupo de un renglon que solo conoce el vehiculo: gastos sin viaje y el
     * sembrado del eje. Devuelve null cuando el vehiculo no tiene propietario o
     * conductor en esa dimension; ese renglon no entra al eje, igual que hoy.
     */
    private String groupKeyForVehicle(String dimension, ScopeVehicleRow vehicle) {
        if (vehicle == null) {
            return null;
        }
        return switch (dimension) {
            case GROUP_VEHICLE -> key(GROUP_VEHICLE, toLong(vehicle.getVehicleId()));
            case GROUP_OWNER -> key(GROUP_OWNER, toLong(vehicle.getOwnerId()));
            case GROUP_DRIVER -> key(GROUP_DRIVER, toLong(vehicle.getCurrentDriverId()));
            default -> null;
        };
    }

    /**
     * Grupo de un renglon nacido de un viaje. El propietario es el del conductor
     * del viaje y solo si no lo tiene se cae al del vehiculo, que es la regla
     * que hoy aplica el cliente.
     */
    private String groupKeyForTrip(String dimension, Long tripDriverId, Long tripDriverOwnerId,
            ScopeVehicleRow vehicle) {
        return switch (dimension) {
            case GROUP_VEHICLE -> vehicle == null ? null : key(GROUP_VEHICLE, toLong(vehicle.getVehicleId()));
            case GROUP_DRIVER -> key(GROUP_DRIVER, tripDriverId);
            case GROUP_OWNER -> tripDriverOwnerId != null
                    ? key(GROUP_OWNER, tripDriverOwnerId)
                    : (vehicle == null ? null : key(GROUP_OWNER, toLong(vehicle.getOwnerId())));
            default -> null;
        };
    }

    private String key(String dimension, Long id) {
        return id == null ? null : dimension + ":" + id;
    }

    private GroupKey parseKey(String key) {
        int separator = key == null ? -1 : key.indexOf(':');
        if (separator < 0) {
            throw ReportException.invalidParameter("La clave del grupo debe tener la forma dimension:id.");
        }
        String type = key.substring(0, separator).trim().toLowerCase();
        String rawId = key.substring(separator + 1).trim();
        if (!GROUP_VEHICLE.equals(type) && !GROUP_OWNER.equals(type) && !GROUP_DRIVER.equals(type)) {
            throw ReportException.invalidParameter("La dimension del grupo debe ser vehicle, owner o driver.");
        }
        try {
            return new GroupKey(type, Long.parseLong(rawId));
        } catch (NumberFormatException e) {
            throw ReportException.invalidParameter("El id del grupo no es numerico: " + rawId);
        }
    }

    /** Claves alcanzables desde los vehiculos del alcance en esa dimension. */
    private Set<String> scopeGroupKeys(Scope scope, String dimension) {
        Set<String> keys = new HashSet<>();
        for (ScopeVehicleRow vehicle : scope.vehicles) {
            String key = groupKeyForVehicle(dimension, vehicle);
            if (key != null) {
                keys.add(key);
            }
        }
        return keys;
    }

    // ---------------------------------------------------------------- Etiquetas

    private Map<String, String> resolveLabels(String dimension, Set<String> keys, Scope scope) {
        if (keys.isEmpty()) {
            return Map.of();
        }
        List<Long> ids = keys.stream().map(this::idOf).toList();

        Map<Long, String> names = switch (dimension) {
            case GROUP_OWNER -> ownerRepository.findAllById(ids).stream()
                    .collect(Collectors.toMap(Owner::getId, Owner::getName, (first, second) -> first));
            case GROUP_DRIVER -> driverRepository.findAllById(ids).stream()
                    .collect(Collectors.toMap(Driver::getId, Driver::getName, (first, second) -> first));
            default -> scope.byVehicleId.entrySet().stream()
                    .filter(entry -> entry.getValue().getPlate() != null)
                    .collect(Collectors.toMap(Map.Entry::getKey, entry -> entry.getValue().getPlate(),
                            (first, second) -> first));
        };

        Map<String, String> labels = new HashMap<>();
        for (String key : keys) {
            labels.put(key, names.getOrDefault(idOf(key), key));
        }
        return labels;
    }

    private Long idOf(String key) {
        return Long.valueOf(key.substring(key.indexOf(':') + 1));
    }

    private String plateOf(Scope scope, Long vehicleId) {
        ScopeVehicleRow vehicle = scope.byVehicleId.get(vehicleId);
        return vehicle == null ? null : vehicle.getPlate();
    }

    /** Un tipo nulo o que ya no exista en el enum cuenta como CARGADO. */
    private String normalizeTripType(String rawTripType) {
        if (rawTripType != null) {
            for (TripTypeEnum tripType : TripTypeEnum.values()) {
                if (tripType.name().equalsIgnoreCase(rawTripType.trim())) {
                    return tripType.name();
                }
            }
        }
        return TripTypeEnum.CARGADO.name();
    }

    private BigDecimal nullSafe(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }

    private Long toLong(Number value) {
        return value == null ? null : value.longValue();
    }

    private int toInt(Number value) {
        return value == null ? 0 : value.intValue();
    }

    private GroupAccumulator accumulator(Map<String, GroupAccumulator> groups, String key) {
        return groups.computeIfAbsent(key, GroupAccumulator::new);
    }

    // ---------------------------------------------------------------- Auxiliares

    private record GroupKey(String type, long id) {
        String key() {
            return type + ":" + id;
        }
    }

    private static class Scope {
        private final List<ScopeVehicleRow> vehicles;
        private final List<Long> vehicleIds;
        private final Map<Long, ScopeVehicleRow> byVehicleId;
        private final String defaultGroupBy;

        Scope(List<ScopeVehicleRow> vehicles, String defaultGroupBy) {
            this.vehicles = vehicles;
            this.vehicleIds = vehicles.stream().map(vehicle -> vehicle.getVehicleId().longValue()).toList();
            this.byVehicleId = vehicles.stream()
                    .collect(Collectors.toMap(vehicle -> vehicle.getVehicleId().longValue(), Function.identity(),
                            (first, second) -> first));
            this.defaultGroupBy = defaultGroupBy;
        }
    }

    private static class GroupAccumulator {
        private final String key;
        private final Set<String> plates = new LinkedHashSet<>();
        private final MonthAccumulator[] months = new MonthAccumulator[MONTHS_IN_YEAR];

        GroupAccumulator(String key) {
            this.key = key;
            for (int index = 0; index < MONTHS_IN_YEAR; index++) {
                months[index] = new MonthAccumulator();
            }
        }

        MonthAccumulator month(int index) {
            return months[index];
        }

        ReportGroupDTO toDto(String label) {
            List<ReportMonthDTO> monthDtos = new ArrayList<>(MONTHS_IN_YEAR);
            for (int index = 0; index < MONTHS_IN_YEAR; index++) {
                monthDtos.add(months[index].toDto(index));
            }
            List<String> plateList = plates.stream().filter(Objects::nonNull).sorted().collect(Collectors.toList());
            return new ReportGroupDTO(key, label, plateList, monthDtos);
        }
    }

    private static class MonthAccumulator {
        private boolean activity;
        private BigDecimal freight = BigDecimal.ZERO;
        private final Map<String, Long> tripsByType = new LinkedHashMap<>();
        private BigDecimal tripExpenses = BigDecimal.ZERO;
        private final Map<Integer, BigDecimal> expensesByType = new LinkedHashMap<>();

        ReportMonthDTO toDto(int index) {
            return new ReportMonthDTO(index, activity, freight,
                    Collections.unmodifiableMap(tripsByType), tripExpenses,
                    Collections.unmodifiableMap(expensesByType));
        }
    }
}
