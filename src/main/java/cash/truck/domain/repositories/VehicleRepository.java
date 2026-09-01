package cash.truck.domain.repositories;

import cash.truck.domain.entities.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;

@Repository
public interface VehicleRepository extends JpaRepository<Vehicle, Long>, JpaSpecificationExecutor<Vehicle> {
    Page<Vehicle> findAll(Specification<Vehicle> specification, Pageable pageable);

    /**
     * Alcance del tablero: un renglon por vehiculo con lo minimo para armar el
     * eje —placa, conductor actual y propietario—. El propietario se resuelve
     * con el vehicle_owner de menor id, que es el que el cliente lee hoy como
     * owners[0].
     *
     * Los filtros usan -1 como "sin filtro" en lugar de nulos: evita depender de
     * como infiere MySQL el tipo de un parametro nulo dentro de la comparacion.
     */
    @Query(value = """
            SELECT v.id                                                        AS vehicleId,
                   v.plate                                                     AS plate,
                   v.current_driver_id                                         AS currentDriverId,
                   (SELECT vo.owner_id FROM vehicle_owner vo
                     WHERE vo.vehicle_id = v.id ORDER BY vo.id LIMIT 1)        AS ownerId
              FROM vehicle v
             WHERE (:ownerId < 0 OR EXISTS (SELECT 1 FROM vehicle_owner vo2
                                             WHERE vo2.vehicle_id = v.id
                                               AND vo2.owner_id = :ownerId))
               AND (:driverId < 0 OR v.current_driver_id = :driverId)
            """, nativeQuery = true)
    List<ScopeVehicleRow> findScopeVehicles(@Param("ownerId") long ownerId, @Param("driverId") long driverId);

    /**
     * Los enteros viajan como Number: MySQL entrega INT o BIGINT segun la
     * expresion y declarar el tipo exacto haria fallar la proyeccion en tiempo
     * de ejecucion por un cast que el compilador no ve.
     */
    interface ScopeVehicleRow {
        Number getVehicleId();

        String getPlate();

        Number getCurrentDriverId();

        Number getOwnerId();
    }
}
