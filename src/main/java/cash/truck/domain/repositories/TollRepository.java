package cash.truck.domain.repositories;

import cash.truck.domain.entities.Toll;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TollRepository extends JpaRepository<Toll, Long> {

    /**
     * Universo de candidatos para emparejar contra una ruta: estaciones activas
     * y georreferenciadas.
     *
     * Las que no tienen coordenadas se descartan en la consulta y no en memoria
     * porque nunca podrian emparejarse: sin punto no hay distancia al trazado.
     * Traerlas solo para filtrarlas despues seria cargar filas para botarlas.
     *
     * El catalogo nacional son unos cientos de filas, asi que se leen todas de
     * una vez y el filtro geometrico se hace en memoria. Acotar por una caja de
     * latitud/longitud en SQL no compensa: obligaria a recorrer la polilinea
     * antes de consultar y el ahorro seria de milisegundos sobre un catalogo
     * que cabe holgadamente en memoria.
     */
    @Query("SELECT t FROM Toll t WHERE t.active = true AND t.latitude IS NOT NULL AND t.longitude IS NOT NULL")
    List<Toll> findActiveGeoReferenced();

    /** Diagnostico del catalogo: cuantas estaciones activas no se pueden emparejar por falta de coordenadas. */
    @Query("SELECT COUNT(t) FROM Toll t WHERE t.active = true AND (t.latitude IS NULL OR t.longitude IS NULL)")
    long countActiveWithoutCoordinates();
}
