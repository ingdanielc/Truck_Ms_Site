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
             GROUP BY t.vehicle_id, t.driver_id, d.owner_id,
                      MONTH(t.start_date), COALESCE(t.trip_type, 'CARGADO')
            """, nativeQuery = true)
    List<TripMonthRow> aggregateTripsByMonth(@Param("year") int year,
            @Param("vehicleIds") Collection<Long> vehicleIds);

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
            @Param("vehicleIds") Collection<Long> vehicleIds);

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
