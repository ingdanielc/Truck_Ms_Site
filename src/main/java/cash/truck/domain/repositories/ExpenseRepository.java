package cash.truck.domain.repositories;

import cash.truck.domain.entities.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.Collection;
import java.util.List;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, Long>, JpaSpecificationExecutor<Expense> {

    /**
     * Gastos de viaje: los que apuntan con trip_id a un viaje del mismo mes en
     * que se registro el gasto. Van por el conductor y propietario del viaje
     * —no por el vehiculo— para que el pie de la tarjeta cuadre con la barra
     * desde la que se abre.
     */
    @Query(value = """
            SELECT e.vehicle_id                        AS vehicleId,
                   t.driver_id                         AS driverId,
                   d.owner_id                          AS driverOwnerId,
                   MONTH(e.expense_date) - 1           AS monthIndex,
                   COALESCE(SUM(e.amount), 0)          AS amount
              FROM expense e
              JOIN trip t ON t.id = e.trip_id
              LEFT JOIN driver d ON d.id = t.driver_id
             WHERE YEAR(e.expense_date) = :year
               AND e.vehicle_id IN (:vehicleIds)
               AND YEAR(t.start_date)  = YEAR(e.expense_date)
               AND MONTH(t.start_date) = MONTH(e.expense_date)
             GROUP BY e.vehicle_id, t.driver_id, d.owner_id, MONTH(e.expense_date)
            """, nativeQuery = true)
    List<TripExpenseMonthRow> aggregateTripExpensesByMonth(@Param("year") int year,
            @Param("vehicleIds") Collection<Long> vehicleIds);

    /**
     * El resto de gastos del mes, por expense_type_id. Incluye mantenimiento y
     * cualquier gasto cuyo viaje caiga en otro mes: el NOT EXISTS cubre ambos
     * casos y tambien el trip_id nulo. Solo puede imputarse por vehiculo, que es
     * la unica via que da expense.
     */
    @Query(value = """
            SELECT e.vehicle_id                        AS vehicleId,
                   MONTH(e.expense_date) - 1           AS monthIndex,
                   c.expense_type_id                   AS expenseTypeId,
                   COALESCE(SUM(e.amount), 0)          AS amount
              FROM expense e
              JOIN expense_category c ON c.id = e.category_id
             WHERE YEAR(e.expense_date) = :year
               AND e.vehicle_id IN (:vehicleIds)
               AND NOT EXISTS (SELECT 1 FROM trip t
                                WHERE t.id = e.trip_id
                                  AND YEAR(t.start_date)  = YEAR(e.expense_date)
                                  AND MONTH(t.start_date) = MONTH(e.expense_date))
             GROUP BY e.vehicle_id, MONTH(e.expense_date), c.expense_type_id
            """, nativeQuery = true)
    List<OtherExpenseMonthRow> aggregateOtherExpensesByMonth(@Param("year") int year,
            @Param("vehicleIds") Collection<Long> vehicleIds);

    /** Mismo "resto" del mes anterior, acotado a un grupo y periodo. Mes -1 = ano completo. */
    @Query(value = """
            SELECT COALESCE(SUM(e.amount), 0)
              FROM expense e
              JOIN vehicle v ON v.id = e.vehicle_id
             WHERE YEAR(e.expense_date) = :year
               AND (:month < 0 OR MONTH(e.expense_date) = :month + 1)
               AND e.vehicle_id IN (:vehicleIds)
               AND NOT EXISTS (SELECT 1 FROM trip t
                                WHERE t.id = e.trip_id
                                  AND YEAR(t.start_date)  = YEAR(e.expense_date)
                                  AND MONTH(t.start_date) = MONTH(e.expense_date))
               AND ((:groupType = 'vehicle' AND e.vehicle_id = :groupId)
                 OR (:groupType = 'driver'  AND v.current_driver_id = :groupId)
                 OR (:groupType = 'owner'   AND (SELECT vo.owner_id FROM vehicle_owner vo
                                                  WHERE vo.vehicle_id = v.id
                                                  ORDER BY vo.id LIMIT 1) = :groupId))
            """, nativeQuery = true)
    BigDecimal sumOtherExpensesForGroup(@Param("year") int year,
            @Param("month") int month,
            @Param("groupType") String groupType,
            @Param("groupId") long groupId,
            @Param("vehicleIds") Collection<Long> vehicleIds);

    /** Ver la nota de tipos en VehicleRepository.ScopeVehicleRow. */
    interface TripExpenseMonthRow {
        Number getVehicleId();

        Number getDriverId();

        Number getDriverOwnerId();

        Number getMonthIndex();

        BigDecimal getAmount();
    }

    interface OtherExpenseMonthRow {
        Number getVehicleId();

        Number getMonthIndex();

        Number getExpenseTypeId();

        BigDecimal getAmount();
    }
}
