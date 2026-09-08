package cash.truck.domain.repositories;

import cash.truck.domain.entities.TollRate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;

@Repository
public interface TollRateRepository extends JpaRepository<TollRate, Long> {

    /**
     * Tarifas candidatas a la fecha de viaje para un conjunto de estaciones.
     *
     * Deliberadamente laxa en dos frentes, porque el catalogo esta incompleto de
     * dos maneras distintas y en ambos casos devolver vacio seria peor que
     * devolver un dato imperfecto:
     *
     * No filtra por endDate. El catalogo se alimenta de resoluciones con corte y
     * hay cargas enteras donde toda tarifa quedo con endDate en el pasado;
     * exigir vigencia estricta dejaria sin importe cualquier viaje posterior al
     * ultimo corte cargado.
     *
     * No pide una sola categoria sino la del vehiculo y las inferiores. Muchas
     * estaciones no publican tarifa de VI ni de VII, y un camion de seis ejes se
     * quedaria sin importe en la mitad de su ruta.
     *
     * Elegir entre las candidatas es del caso de uso: la escala de categorias es
     * en numeros romanos y ordenarla en SQL exigiria un CASE por valor.
     */
    @Query("""
            SELECT r FROM TollRate r
             WHERE r.tollId IN :tollIds
               AND r.category IN :categories
               AND r.startDate <= :travelDate
             ORDER BY r.tollId, r.startDate DESC
            """)
    List<TollRate> findApplicableRates(@Param("tollIds") Collection<Long> tollIds,
            @Param("categories") Collection<String> categories,
            @Param("travelDate") LocalDate travelDate);
}
