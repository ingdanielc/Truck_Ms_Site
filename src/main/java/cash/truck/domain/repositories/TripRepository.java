package cash.truck.domain.repositories;

import cash.truck.domain.entities.Trip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;

import java.math.BigDecimal;
import java.util.Collection;
import java.util.Date;
import java.util.List;

@Repository
public interface TripRepository extends JpaRepository<Trip, Long> {
    Page<Trip> findAll(Specification<Trip> specification, Pageable pageable);

    /**
     * Viajes del ano agregados por vehiculo, conductor, mes y tipo. Se agrega a
     * ese grano y no directamente por grupo porque el propietario de un viaje es
     * driver.ownerId con respaldo en el propietario del vehiculo: dejar esa
     * regla en Java la mantiene en un solo lugar para las tres dimensiones.
     *
     * El mes sale de start_date. La conexion abre en America/Bogota, asi que
     * MONTH() ya evalua en hora local.
     *
     * Los cancelados quedan fuera: son la baja logica de un viaje que nunca
     * rodo, y su flete no es ingreso.
     */
    @Query(value = """
            SELECT t.vehicle_id                        AS vehicleId,
                   t.driver_id                         AS driverId,
                   d.owner_id                          AS driverOwnerId,
                   MONTH(t.start_date) - 1             AS monthIndex,
                   COALESCE(t.trip_type, 'CARGADO')    AS tripType,
                   COUNT(*)                            AS trips,
                   COALESCE(SUM(t.freight), 0)         AS freight
              FROM trip t
              LEFT JOIN driver d ON d.id = t.driver_id
             WHERE YEAR(t.start_date) = :year
               AND t.vehicle_id IN (:vehicleIds)
               AND (t.status IS NULL OR t.status <> :cancelledStatus)
             GROUP BY t.vehicle_id, t.driver_id, d.owner_id,
                      MONTH(t.start_date), COALESCE(t.trip_type, 'CARGADO')
            """, nativeQuery = true)
    List<TripMonthRow> aggregateTripsByMonth(@Param("year") int year,
            @Param("vehicleIds") Collection<Long> vehicleIds,
            @Param("cancelledStatus") String cancelledStatus);

    /** Viajes en curso del alcance. Sin filtro de fecha, igual que hoy. */
    @Query(value = """
            SELECT t.id                                AS tripId,
                   t.number_trip                       AS numberTrip,
                   v.plate                             AS plate,
                   t.origin_id                         AS originId,
                   t.destination_id                    AS destinationId,
                   t.start_date                        AS startDate,
                   t.freight                           AS freight,
                   COALESCE((SELECT SUM(e.amount) FROM expense e
                              WHERE e.trip_id = t.id), 0) AS expenses
              FROM trip t
              JOIN vehicle v ON v.id = t.vehicle_id
             WHERE t.status = :status
               AND t.vehicle_id IN (:vehicleIds)
             ORDER BY t.start_date DESC
            """, nativeQuery = true)
    List<ActiveTripRow> findActiveTrips(@Param("status") String status,
            @Param("vehicleIds") Collection<Long> vehicleIds);

    /**
     * Detalle de un grupo. La pertenencia se resuelve en SQL para no traer los
     * viajes de todo el alcance y descartarlos en memoria. Mes -1 = ano completo.
     *
     * Sin los cancelados, igual que el agregado del tablero: las filas de este
     * detalle tienen que sumar lo mismo que la barra desde la que se abre.
     */
    @Query(value = """
            SELECT t.id                                AS id,
                   t.number_trip                       AS numberTrip,
                   v.plate                             AS plate,
                   MONTH(t.start_date) - 1             AS monthIndex,
                   t.freight                           AS freight,
                   t.origin_id                         AS originId,
                   t.destination_id                    AS destinationId,
                   t.load_type                         AS loadType,
                   t.number_of_days                    AS numberOfDays,
                   COALESCE((SELECT SUM(e.amount) FROM expense e
                              WHERE e.trip_id = t.id
                                AND YEAR(e.expense_date) = :year
                                AND (:month < 0 OR MONTH(e.expense_date) = :month + 1)), 0) AS expenses
              FROM trip t
              JOIN vehicle v ON v.id = t.vehicle_id
              LEFT JOIN driver d ON d.id = t.driver_id
             WHERE YEAR(t.start_date) = :year
               AND (:month < 0 OR MONTH(t.start_date) = :month + 1)
               AND t.vehicle_id IN (:vehicleIds)
               AND (t.status IS NULL OR t.status <> :cancelledStatus)
               AND ((:groupType = 'vehicle' AND t.vehicle_id = :groupId)
                 OR (:groupType = 'driver'  AND t.driver_id  = :groupId)
                 OR (:groupType = 'owner'   AND COALESCE(d.owner_id,
                        (SELECT vo.owner_id FROM vehicle_owner vo
                          WHERE vo.vehicle_id = v.id ORDER BY vo.id LIMIT 1)) = :groupId))
             ORDER BY t.start_date
            """, nativeQuery = true)
    List<TripDetailRow> findGroupTrips(@Param("year") int year,
            @Param("month") int month,
            @Param("groupType") String groupType,
            @Param("groupId") long groupId,
            @Param("vehicleIds") Collection<Long> vehicleIds,
            @Param("cancelledStatus") String cancelledStatus);

    /**
     * Viajes en curso que llevan mas de las horas indicadas sin un solo gasto.
     *
     * El propietario se resuelve aqui y no en Java —driver.owner_id con
     * respaldo en vehicle_owner— por la misma regla que usa el detalle de
     * grupos: un viaje pertenece al propietario del conductor y, si el
     * conductor no lo tiene, al del vehiculo.
     *
     * No excluye los viajes ya avisados: eso lo decide el planificador
     * consultando la notificacion por reference_id, para no meter la tabla de
     * notificaciones en una consulta de viajes.
     */
    @Query(value = """
            SELECT t.id                                AS tripId,
                   t.number_trip                       AS numberTrip,
                   v.plate                             AS plate,
                   t.driver_id                         AS driverId,
                   t.start_date                        AS eventDate,
                   COALESCE(d.owner_id,
                       (SELECT vo.owner_id FROM vehicle_owner vo
                         WHERE vo.vehicle_id = v.id ORDER BY vo.id LIMIT 1)) AS ownerId
              FROM trip t
              JOIN vehicle v ON v.id = t.vehicle_id
              LEFT JOIN driver d ON d.id = t.driver_id
             WHERE t.status = :inProgressStatus
               AND t.start_date <= :threshold
               AND NOT EXISTS (SELECT 1 FROM expense e WHERE e.trip_id = t.id)
             ORDER BY t.start_date
            """, nativeQuery = true)
    List<InactiveTripRow> findInProgressTripsWithoutExpenses(
            @Param("inProgressStatus") String inProgressStatus,
            @Param("threshold") Date threshold);

    /**
     * Ultimo viaje de cada conductor cuando ya se cerro hace mas de las horas
     * indicadas y no se abrio ninguno despues.
     *
     * "Ultimo" se decide por id y no por fecha: el id es monotono y no depende
     * de que start_date venga bien informado. La condicion de no tener un viaje
     * posterior tambien garantiza una sola fila por conductor, de modo que el
     * planificador no necesita agrupar en memoria.
     *
     * Los cancelados no cuentan como viaje siguiente —son la baja logica de un
     * viaje que nunca rodo— ni pueden disparar el aviso ellos mismos.
     */
    @Query(value = """
            SELECT t.id                                AS tripId,
                   t.number_trip                       AS numberTrip,
                   v.plate                             AS plate,
                   t.driver_id                         AS driverId,
                   t.end_date                          AS eventDate,
                   COALESCE(d.owner_id,
                       (SELECT vo.owner_id FROM vehicle_owner vo
                         WHERE vo.vehicle_id = v.id ORDER BY vo.id LIMIT 1)) AS ownerId
              FROM trip t
              JOIN vehicle v ON v.id = t.vehicle_id
              LEFT JOIN driver d ON d.id = t.driver_id
             WHERE t.status IS NOT NULL
               AND t.status <> :inProgressStatus
               AND t.status <> :cancelledStatus
               AND t.end_date IS NOT NULL
               AND t.end_date <= :threshold
               AND NOT EXISTS (SELECT 1 FROM trip t2
                                WHERE t2.driver_id = t.driver_id
                                  AND t2.id > t.id
                                  AND (t2.status IS NULL OR t2.status <> :cancelledStatus))
             ORDER BY t.end_date
            """, nativeQuery = true)
    List<InactiveTripRow> findClosedTripsWithoutFollowUp(
            @Param("inProgressStatus") String inProgressStatus,
            @Param("cancelledStatus") String cancelledStatus,
            @Param("threshold") Date threshold);

    /**
     * Viajes que siguen en curso desde hace mas del umbral, sin que nadie los
     * haya pasado a Pendiente ni a Completado.
     *
     * No hace falta nombrar esos dos estados en el WHERE: un viaje que ya paso
     * a cualquiera de ellos deja de cumplir status = :inProgressStatus y sale
     * de la consulta por si solo. Nombrarlos solo abriria la puerta a que un
     * estado nuevo del ENUM se colara como "en curso".
     *
     * Se mide desde start_date y no desde update_date: update_date se mueve con
     * cualquier edicion del viaje —corregir el flete, marcar el saldo pagado— y
     * eso aplazaria el aviso en silencio cada vez que alguien toca la fila.
     */
    @Query(value = """
            SELECT t.id                                AS tripId,
                   t.number_trip                       AS numberTrip,
                   v.plate                             AS plate,
                   t.driver_id                         AS driverId,
                   t.start_date                        AS eventDate,
                   COALESCE(d.owner_id,
                       (SELECT vo.owner_id FROM vehicle_owner vo
                         WHERE vo.vehicle_id = v.id ORDER BY vo.id LIMIT 1)) AS ownerId
              FROM trip t
              JOIN vehicle v ON v.id = t.vehicle_id
              LEFT JOIN driver d ON d.id = t.driver_id
             WHERE t.status = :inProgressStatus
               AND t.start_date <= :threshold
             ORDER BY t.start_date
            """, nativeQuery = true)
    List<InactiveTripRow> findStalledInProgressTrips(
            @Param("inProgressStatus") String inProgressStatus,
            @Param("threshold") Date threshold);

    /**
     * Fila de los tres avisos de inactividad. eventDate es start_date en los de
     * gastos y viaje estancado, y end_date en el de viaje sin relevo: el
     * mensaje solo necesita saber desde cuando se cuenta, no cual de las dos
     * columnas lo origino.
     */
    interface InactiveTripRow {
        Number getTripId();

        String getNumberTrip();

        String getPlate();

        Number getDriverId();

        Date getEventDate();

        Number getOwnerId();
    }

    /** Ver la nota de tipos en VehicleRepository.ScopeVehicleRow. */
    interface TripMonthRow {
        Number getVehicleId();

        Number getDriverId();

        Number getDriverOwnerId();

        Number getMonthIndex();

        String getTripType();

        Number getTrips();

        BigDecimal getFreight();
    }

    interface ActiveTripRow {
        Number getTripId();

        String getNumberTrip();

        String getPlate();

        String getOriginId();

        String getDestinationId();

        Date getStartDate();

        BigDecimal getFreight();

        BigDecimal getExpenses();
    }

    interface TripDetailRow {
        Number getId();

        String getNumberTrip();

        String getPlate();

        Number getMonthIndex();

        BigDecimal getFreight();

        String getOriginId();

        String getDestinationId();

        String getLoadType();

        Number getNumberOfDays();

        BigDecimal getExpenses();
    }
}
